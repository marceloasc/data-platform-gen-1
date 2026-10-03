create view [analytics].[operation] as 

with products as (
	select distinct
		p.ProductID as id_produto,
		(
			select top 1 value 
			from string_split(upper(replace(trim(p."Name"), '  ', '')), ',')

		) as produto,
		iif(psc."Name" is null, 'NÃO APLICÁVEL', upper(trim(psc."Name"))) as sub_categoria_produto,
		iif(pc."Name" is null, 'NÃO APLICÁVEL', upper(trim(pc."Name"))) as categoria_produto
	from Production.Product p
		left join Production.ProductSubcategory psc
			on psc.ProductSubcategoryID = p.ProductSubcategoryID
		left join Production.ProductCategory pc
			on pc.ProductCategoryID = psc.ProductCategoryID
),

customer as (
	select
		CustomerID as id_cliente,
		iif(PersonID is null, 'PJ', 'PF') as tipo_cliente
	from Sales.Customer
),

sales_person as (
	select
		sp.BusinessEntityID as id_vendedor,
		concat(
			upper(trim(pp.FirstName)), ' ', 
			iif(
				pp.MiddleName is not null, 
				concat(upper(trim(pp.MiddleName)), ' '), ''
			),
			upper(trim(pp.LastName))
		) as vendedor
	from Sales.SalesPerson sp
		inner join Person.Person pp
			on pp.BusinessEntityID = sp.BusinessEntityID
),

territory as (
	select
		TerritoryID as id_local,
		case
			when upper(trim(CountryRegionCode)) = 'US' then 'UNITED STATES'
			else upper(trim("Name"))
		end as local,
		upper(trim("Group")) as regiao
	from Sales.SalesTerritory st
),

order_header as (
	select
		soh.SalesOrderID as id_pedido,
		cast(soh.OrderDate as date) as "data",
		cust.tipo_cliente as tipo_cliente,
		iif(sp.vendedor is null, 'NÃO IDENTIFICADO', sp.vendedor) as vendedor,
		ter."local" as "local",
		ter.regiao as regiao
	from Sales.SalesOrderHeader soh
		left join customer cust
			on cust.id_cliente = soh.CustomerID
		left join sales_person sp
			on sp.id_vendedor = soh.SalesPersonID
		inner join territory ter
			on ter.id_local = soh.TerritoryID
),

order_detail as (
	select
		sod.SalesOrderID as id_pedido_item,
		sod.SalesOrderDetailID as id_item,
		p.id_produto,
		p.produto as produto,
		p.categoria_produto,
		p.sub_categoria_produto,
		sod.OrderQty as quantidade_produto,
		sod.LineTotal as faturamento
	from Sales.SalesOrderDetail sod
		inner join products p
			on p.id_produto = sod.ProductID
),

calendar as (
	select
		"date" as "data",
		"year" as ano,
		"month" as mes,
		month_name as nome_mes,
		month_label as rotulo_mes,
		month_year_label as rotulo_mes_ano,
		first_month_day as primeiro_dia_mes,
		last_month_day as ultimo_dia_mes,
		"quarter" as trimestre,
		quarter_label as rotulo_trimestre
	from analytics.calendar 
	where "date" between (select min("data") from order_header)
			   and (select max("data") from order_header)
)	

select
	c.ano,
	c.mes,
	c.nome_mes,
	c.rotulo_mes,
	c.rotulo_mes_ano,
	c.primeiro_dia_mes,
	c.ultimo_dia_mes,
	c.trimestre,
	c.rotulo_trimestre,
	oh.tipo_cliente,
	oh.vendedor,
	oh."local",
	oh.regiao,
	od.produto,
	od.categoria_produto,
	od.sub_categoria_produto,
	sum(iif(od.faturamento is null, 0, od.faturamento)) as faturamento,
	count(distinct id_pedido) as pedidos,
	sum(od.quantidade_produto) as itens_vendidos
from order_header oh
	inner join order_detail as od
		on od.id_pedido_item = oh.id_pedido
	left join calendar c
		on c."data" = oh."data"
group by c.ano,
		 c.mes,
		 c.nome_mes,
		 c.rotulo_mes,
		 c.rotulo_mes_ano,
		 c.primeiro_dia_mes,
		 c.ultimo_dia_mes,
		 c.trimestre,
		 c.rotulo_trimestre,
		 oh.tipo_cliente,
		 oh.vendedor,
		 oh."local",
		 oh.regiao,
		 od.produto,
		 od.categoria_produto,
		 od.sub_categoria_produto,
		 od.quantidade_produto
