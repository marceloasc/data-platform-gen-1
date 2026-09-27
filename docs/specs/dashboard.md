# Especificação Funcional --- Visão Geral da Operação AdventureWorks

**Arquivo:** `Relatório_Operacional.xlsx`\
**Fonte:** banco transacional AdventureWorks\
**Escopo:** uma única aba de dashboard

------------------------------------------------------------------------

## 1. Estrutura do relatório

O arquivo deverá conter somente a aba **DASHBOARD**, reunindo os
principais indicadores de vendas, clientes, produtos e vendedores.

A referência temporal das análises será
`Sales.SalesOrderHeader.OrderDate`.

------------------------------------------------------------------------

## 2. Fontes de dados

### Vendas

-   `Sales.SalesOrderHeader`
-   `Sales.SalesOrderDetail`

### Produtos

-   `Production.Product`
-   `Production.ProductSubcategory`
-   `Production.ProductCategory`

### Clientes e vendedores

-   `Sales.Customer`
-   `Sales.SalesPerson`
-   `Person.Person`
-   `Sales.SalesTerritory`

Os relacionamentos principais são:

``` text
SalesOrderHeader.SalesOrderID
    = SalesOrderDetail.SalesOrderID

SalesOrderDetail.ProductID
    = Product.ProductID

Product.ProductSubcategoryID
    = ProductSubcategory.ProductSubcategoryID

ProductSubcategory.ProductCategoryID
    = ProductCategory.ProductCategoryID

SalesOrderHeader.CustomerID
    = Customer.CustomerID

SalesOrderHeader.SalesPersonID
    = SalesPerson.BusinessEntityID

SalesPerson.BusinessEntityID
    = Person.BusinessEntityID

SalesOrderHeader.TerritoryID
    = SalesTerritory.TerritoryID
```

Produtos sem subcategoria e pedidos sem vendedor devem ser preservados
quando aplicável.

------------------------------------------------------------------------

## 3. Campos necessários na origem analítica

A origem que alimentará o dashboard deverá disponibilizar, no mínimo:

### Pedido

-   `SalesOrderID`
-   `OrderDate`
-   `CustomerID`
-   `SalesPersonID`
-   `TerritoryID`

### Item da venda

-   `SalesOrderDetailID`
-   `ProductID`
-   `OrderQty`
-   `UnitPrice`
-   `UnitPriceDiscount`
-   `LineTotal`

### Produto

-   `Product.Name` como `ProductName`
-   `ProductSubcategory.Name` como `SubcategoryName`
-   `ProductCategory.Name` como `CategoryName`

### Cliente

-   `Customer.CustomerID`

### Vendedor

-   `SalesPerson.BusinessEntityID`
-   `Person.FirstName`
-   `Person.MiddleName`
-   `Person.LastName`
-   nome completo derivado como `SalesPersonName`

### Território

-   `SalesTerritory.Name` como `TerritoryName`

### Calendário

Derivado de `OrderDate`: - Ano - Número do mês - Mês - Ano/Mês

------------------------------------------------------------------------

## 4. KPIs

### Faturamento

``` text
SUM(SalesOrderDetail.LineTotal)
```

### Pedidos

``` text
COUNT(DISTINCT SalesOrderID)
```

### Itens vendidos

``` text
SUM(OrderQty)
```

### Ticket médio

``` text
SUM(LineTotal) / COUNT(DISTINCT SalesOrderID)
```

### Clientes que compraram

``` text
COUNT(DISTINCT CustomerID)
```

### Produtos vendidos

``` text
COUNT(DISTINCT ProductID)
```

Os indicadores devem respeitar os filtros aplicados ao dashboard.

------------------------------------------------------------------------

## 5. Visualizações

### Evolução do faturamento

**Visualização:** gráfico de linha.

``` text
Eixo X = Ano/Mês de OrderDate
Eixo Y = SUM(LineTotal)
```

### Faturamento por categoria

**Visualização:** gráfico de barras.

``` text
Categoria = ProductCategory.Name
Métrica = SUM(LineTotal)
```

### Top 10 produtos

**Visualização:** barras horizontais.

``` text
Produto = Product.Name
Métrica = SUM(LineTotal)
Ordenação = decrescente
Limite = 10
```

### Faturamento por território

**Visualização:** gráfico de barras.

``` text
Território = SalesTerritory.Name
Métrica = SUM(LineTotal)
```

O território deverá ser obtido por `SalesOrderHeader.TerritoryID`.

### Faturamento por vendedor

**Visualização:** barras horizontais.

``` text
Vendedor = SalesPersonName
Métrica = SUM(LineTotal)
Ordenação = decrescente
```

Pedidos com `SalesPersonID` nulo não devem ser atribuídos
artificialmente a um vendedor.

------------------------------------------------------------------------

## 6. Filtros

A aba deverá possuir os seguintes filtros:

-   Ano
-   Mês
-   Território
-   Categoria
-   Subcategoria
-   Vendedor

Todos os filtros devem atualizar os KPIs e as visualizações aplicáveis.

------------------------------------------------------------------------

## 7. Organização da aba

``` text
┌─────────────────────────────────────────────────────────────────┐
│                  DASHBOARD DA OPERAÇÃO                        │
├─────────────────────────────────────────────────────────────────┤
│ Ano | Mês | Território | Categoria | Subcategoria | Vendedor   │
├───────────┬──────────┬───────────┬───────────┬─────────────────┤
│Faturamento│ Pedidos  │Itens vend.│Ticket médio│Clientes ativos │
├───────────┴──────────┴───────────┴───────────┴─────────────────┤
│                 EVOLUÇÃO DO FATURAMENTO                         │
│                       Linha                                     │
├───────────────────────────────┬─────────────────────────────────┤
│ FATURAMENTO POR CATEGORIA     │ TOP 10 PRODUTOS                 │
│ Barras                        │ Barras horizontais              │
├───────────────────────────────┼─────────────────────────────────┤
│ FATURAMENTO POR TERRITÓRIO    │ FATURAMENTO POR VENDEDOR        │
│ Barras                        │ Barras horizontais              │
└───────────────────────────────┴─────────────────────────────────┘
```

------------------------------------------------------------------------

## 8. Regras importantes

### Granularidade

`SalesOrderHeader` possui uma linha por pedido, enquanto
`SalesOrderDetail` possui uma ou mais linhas por pedido.

Por isso:

``` text
Pedidos = COUNT(DISTINCT SalesOrderID)
```

e nunca simplesmente `COUNT(SalesOrderID)` após o join com os itens.

### Faturamento

O faturamento comercial utilizado no dashboard será:

``` text
SUM(SalesOrderDetail.LineTotal)
```

`LineTotal` representa o valor da linha após aplicação do desconto.

### Métricas do cabeçalho

Campos como `TaxAmt`, `Freight` e `TotalDue` não fazem parte dos KPIs
desta versão. Caso sejam adicionados futuramente, não poderão ser
somados diretamente após o join entre `SalesOrderHeader` e
`SalesOrderDetail`, pois seriam repetidos por item do pedido.

### Top 10

O Top 10 de produtos deverá ser calculado depois da aplicação dos
filtros.

------------------------------------------------------------------------

## 9. Critérios de aceite

1.  O arquivo deverá possuir somente a aba **DASHBOARD**.
2.  Os KPIs deverão responder aos filtros aplicáveis.
3.  O faturamento deverá ser calculado por `SUM(LineTotal)`.
4.  Pedidos deverão ser contados de forma distinta por `SalesOrderID`.
5.  A análise temporal deverá utilizar `OrderDate`.
6.  Categorias e subcategorias deverão ser obtidas pela hierarquia
    `Product → ProductSubcategory → ProductCategory`.
7.  O território da venda deverá ser obtido por
    `SalesOrderHeader.TerritoryID`.
8.  O vendedor deverá ser relacionado por
    `SalesOrderHeader.SalesPersonID = SalesPerson.BusinessEntityID`.
9.  Pedidos sem vendedor deverão permanecer sem atribuição.
10. O Top 10 deverá respeitar o contexto dos filtros.
