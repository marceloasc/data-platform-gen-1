# Especificação Funcional --- Dashboard Operacional AdventureWorks

**Arquivo:** `Relatório_Operacional.xlsx`\
**Fonte:** banco transacional AdventureWorks\
**Tipo:** Especificação funcional / User Story\
**Versão:** 1.0

------------------------------------------------------------------------

## 1. User Story

> **Como usuário responsável pelo acompanhamento operacional e
> comercial, quero consultar um arquivo Excel chamado
> `Relatório_Operacional.xlsx`, organizado por áreas de negócio, para
> acompanhar vendas, produtos, clientes e vendedores por meio de
> indicadores, gráficos e filtros interativos, utilizando os dados do
> banco transacional AdventureWorks.**

Esta especificação define - fontes transacionais relevantes; - indicadores
e respectivos cálculos; - visualizações; - organização das abas; -
filtros; - critérios de aceite.

------------------------------------------------------------------------

# 2. Estrutura do arquivo

O arquivo deverá conter as seguintes abas:

  Aba               Objetivo
  ----------------- -------------------------------------------------
  **Vendas**        Desempenho comercial e evolução das vendas
  **Produtos**      Produtos, categorias, volume, receita e estoque
  **Clientes**      Base, comportamento e contribuição dos clientes
  **Vendedores**    Desempenho dos vendedores

------------------------------------------------------------------------

# 3. Fontes por área

## 3.1 Vendas

### Principais

-   `Sales.SalesOrderHeader`
-   `Sales.SalesOrderDetail`

### Complementares

-   `Production.Product`
-   `Production.ProductSubcategory`
-   `Production.ProductCategory`
-   `Sales.Customer`
-   `Sales.SalesTerritory`
-   `Sales.SalesPerson`
-   `Sales.SpecialOffer`
-   `Sales.SpecialOfferProduct`
-   `Production.Currency`
-   `Sales.CurrencyRate`

## 3.2 Produtos

### Principais

-   `Production.Product`
-   `Production.ProductSubcategory`
-   `Production.ProductCategory`

### Complementares

-   `Sales.SalesOrderDetail`
-   `Production.ProductInventory`
-   `Production.ProductCostHistory`
-   `Production.ProductListPriceHistory`
-   `Sales.SpecialOfferProduct`
-   `Sales.SpecialOffer`
-   `Production.ProductModel`
-   `Production.ProductPhoto`
-   `Production.Illustration`

## 3.3 Clientes

### Principais

-   `Sales.Customer`
-   `Person.Person`
-   `Sales.Store`

### Complementares

-   `Sales.SalesOrderHeader`
-   `Sales.SalesOrderDetail`
-   `Sales.SalesTerritory`
-   `Person.BusinessEntity`
-   `Person.BusinessEntityAddress`
-   `Person.Address`
-   `Person.StateProvince`
-   `Person.CountryRegion`

## 3.4 Vendedores

### Principais

-   `Sales.SalesPerson`
-   `Sales.SalesOrderHeader`

### Complementares

-   `Sales.SalesOrderDetail`
-   `Person.Person`
-   `Person.BusinessEntity`
-   `Sales.SalesTerritory`
-   `Sales.SalesTerritoryHistory`

------------------------------------------------------------------------

# 4. Etapa 1 --- Indicadores e cálculos

## 4.1 Vendas

### Faturamento

**Fonte:** `Sales.SalesOrderDetail.LineTotal`

``` text
Faturamento = SUM(LineTotal)
```

### Pedidos

**Fonte:** `Sales.SalesOrderHeader.SalesOrderID`

``` text
Pedidos = COUNT(DISTINCT SalesOrderID)
```

Deve ser usada a quantidade distinta de pedidos, pois um pedido pode
possuir várias linhas.

### Itens vendidos

**Fonte:** `Sales.SalesOrderDetail.OrderQty`

``` text
Itens vendidos = SUM(OrderQty)
```

### Ticket médio

``` text
Ticket médio = Faturamento / Número de pedidos
```

### Valor médio por item

``` text
Valor médio por item = Faturamento / Itens vendidos
```

### Desconto concedido

**Fontes:** `OrderQty`, `UnitPrice`, `UnitPriceDiscount`

``` text
Desconto =
SUM(OrderQty × UnitPrice × UnitPriceDiscount)
```

### Impostos

**Fonte:** `Sales.SalesOrderHeader.TaxAmt`

``` text
Impostos = SUM(TaxAmt)
```

### Frete

**Fonte:** `Sales.SalesOrderHeader.Freight`

``` text
Frete = SUM(Freight)
```

------------------------------------------------------------------------

## 4.2 Produtos

### Produtos cadastrados

``` text
Produtos cadastrados = COUNT(DISTINCT ProductID)
```

### Produtos vendidos

**Fonte:** `Sales.SalesOrderDetail`

``` text
Produtos vendidos = COUNT(DISTINCT ProductID)
```

### Quantidade vendida

``` text
Quantidade vendida = SUM(OrderQty)
```

### Faturamento por produto

``` text
Faturamento por produto = SUM(LineTotal)
```

### Preço médio ponderado

``` text
Preço médio =
SUM(UnitPrice × OrderQty) / SUM(OrderQty)
```

Evitar `AVG(UnitPrice)` quando o objetivo for representar o preço médio
efetivamente praticado por unidade.

### Estoque total

**Fonte:** `Production.ProductInventory.Quantity`

``` text
Estoque total = SUM(Quantity)
```

### Produtos sem estoque

``` text
Produtos sem estoque =
COUNT(DISTINCT ProductID WHERE Quantity = 0)
```

------------------------------------------------------------------------

## 4.3 Clientes

### Clientes cadastrados

**Fonte:** `Sales.Customer.CustomerID`

``` text
Clientes cadastrados = COUNT(DISTINCT CustomerID)
```

### Clientes que compraram

**Fonte:** `Sales.SalesOrderHeader.CustomerID`

``` text
Clientes que compraram =
COUNT(DISTINCT CustomerID)
```

O indicador deverá considerar o período selecionado.

### Faturamento por cliente

``` text
Faturamento do cliente = SUM(LineTotal)
```

### Pedidos por cliente

``` text
Pedidos do cliente = COUNT(DISTINCT SalesOrderID)
```

### Ticket médio por cliente

``` text
Ticket médio =
Faturamento do cliente / Pedidos do cliente
```

### Participação na receita

``` text
Participação =
Faturamento do cliente / Faturamento total × 100
```

------------------------------------------------------------------------

## 4.4 Vendedores

### Número de vendedores

**Fonte:** `Sales.SalesPerson.BusinessEntityID`

``` text
Vendedores = COUNT(DISTINCT BusinessEntityID)
```

### Faturamento por vendedor

``` text
Faturamento do vendedor = SUM(LineTotal)
```

Agrupado pelo vendedor associado ao pedido.

### Pedidos por vendedor

``` text
Pedidos do vendedor =
COUNT(DISTINCT SalesOrderID)
```

### Ticket médio

``` text
Ticket médio =
Faturamento do vendedor / Pedidos do vendedor
```

### Participação na receita

``` text
Participação =
Faturamento do vendedor / Faturamento total × 100
```

### Vendas atribuídas a vendedores

``` text
% vendas atribuídas =
Pedidos com SalesPersonID preenchido
/
Total de pedidos × 100
```

Também deverá ser possível identificar pedidos sem vendedor atribuído.

------------------------------------------------------------------------

# 5. Etapa 2 --- Aba Vendas

## Objetivo

Permitir acompanhar a evolução das vendas e identificar produtos,
categorias e territórios que mais contribuem para o faturamento.

## Organização

``` text
┌─────────────────────────────────────────────────────────────┐
│                    DASHBOARD — VENDAS                       │
├─────────────────────────────────────────────────────────────┤
│ Filtros: Ano | Mês | Território | Categoria | Subcategoria │
├────────────┬────────────┬────────────┬────────────┬─────────┤
│Faturamento │  Pedidos   │Itens vend. │Ticket méd. │Desconto │
├────────────┴────────────┴────────────┴────────────┴─────────┤
│              EVOLUÇÃO DO FATURAMENTO                        │
│                   Gráfico de linha                          │
├─────────────────────────────┬───────────────────────────────┤
│ FATURAMENTO POR CATEGORIA   │ TOP 10 PRODUTOS               │
│ Barras                      │ Barras                        │
├─────────────────────────────┼───────────────────────────────┤
│ FATURAMENTO POR TERRITÓRIO  │ PEDIDOS POR MÊS               │
│ Barras                      │ Colunas                       │
└─────────────────────────────┴───────────────────────────────┘
```

### KPIs

-   Faturamento
-   Pedidos
-   Itens vendidos
-   Ticket médio
-   Desconto concedido

Indicadores secundários: - Impostos - Frete - Valor médio por item

### Evolução do faturamento

**Fontes:** `SalesOrderHeader.OrderDate` e `SalesOrderDetail.LineTotal`

``` text
Eixo X = Ano/Mês
Eixo Y = SUM(LineTotal)
```

**Visualização:** linha.

### Faturamento por categoria

**Fontes:** `SalesOrderDetail`, `Product`, `ProductSubcategory`,
`ProductCategory`

``` text
Métrica = SUM(LineTotal)
Agrupamento = ProductCategory
```

**Visualização:** barras horizontais.

### Top 10 produtos

``` text
Métrica = SUM(LineTotal)
Agrupamento = Produto
Ordenação = Faturamento DESC
Limite = 10
```

**Visualização:** barras horizontais.

### Faturamento por território

``` text
Métrica = SUM(LineTotal)
Agrupamento = SalesTerritory.Name
```

**Visualização:** barras.

### Pedidos por mês

``` text
Métrica = COUNT(DISTINCT SalesOrderID)
Agrupamento = Ano/Mês de OrderDate
```

**Visualização:** colunas.

------------------------------------------------------------------------

# 6. Etapa 3 --- Aba Produtos

## Objetivo

Identificar produtos e categorias de maior relevância comercial e
acompanhar informações básicas de estoque.

## Organização

``` text
┌─────────────────────────────────────────────────────────────┐
│                   DASHBOARD — PRODUTOS                     │
├─────────────────────────────────────────────────────────────┤
│ Filtros: Categoria | Subcategoria | Produto                  │
├──────────────┬──────────────┬──────────────┬────────────────┤
│Produtos vend.│Itens vendidos│ Faturamento  │ Preço médio     │
├──────────────┴──────────────┴──────────────┴────────────────┤
│              FATURAMENTO POR CATEGORIA                      │
│                   Gráfico de barras                         │
├─────────────────────────────┬───────────────────────────────┤
│ TOP 10 PRODUTOS             │ QUANTIDADE POR CATEGORIA      │
│ Barras                      │ Barras                        │
├─────────────────────────────┼───────────────────────────────┤
│ DESCONTO POR CATEGORIA      │ ESTOQUE POR CATEGORIA         │
│ Barras                      │ Barras                        │
└─────────────────────────────┴───────────────────────────────┘
```

### KPIs

-   Produtos vendidos
-   Itens vendidos
-   Faturamento
-   Preço médio
-   Estoque total
-   Produtos sem estoque

### Faturamento por categoria

``` text
Métrica = SUM(LineTotal)
Agrupamento = ProductCategory
```

**Visualização:** barras.

### Top 10 produtos

``` text
Métrica = SUM(LineTotal)
Ordenação = DESC
Limite = 10
```

**Visualização:** barras horizontais.

### Quantidade vendida por categoria

``` text
Métrica = SUM(OrderQty)
Agrupamento = ProductCategory
```

**Visualização:** barras.

### Desconto por categoria

``` text
Métrica =
SUM(OrderQty × UnitPrice × UnitPriceDiscount)
Agrupamento = ProductCategory
```

**Visualização:** barras.

### Estoque

**Fonte:** `Production.ProductInventory`

``` text
Métrica = SUM(Quantity)
```

**Agrupamento possível:** categoria, produto ou localização.

**Visualização:** barras.

------------------------------------------------------------------------

# 7. Etapa 4 --- Aba Clientes

## Objetivo

Analisar a base de clientes, seu comportamento de compra e sua
contribuição para o faturamento.

## Organização

``` text
┌─────────────────────────────────────────────────────────────┐
│                   DASHBOARD — CLIENTES                     │
├─────────────────────────────────────────────────────────────┤
│ Filtros: Território | País | Estado | Tipo de cliente      │
├──────────────┬──────────────┬──────────────┬────────────────┤
│  Clientes    │ Clientes que │ Faturamento │ Ticket médio   │
│ cadastrados  │  compraram   │              │                │
├──────────────┴──────────────┴──────────────┴────────────────┤
│               EVOLUÇÃO DE CLIENTES                          │
│                   Gráfico de linha                          │
├─────────────────────────────┬───────────────────────────────┤
│ TOP 10 CLIENTES             │ FATURAMENTO POR TERRITÓRIO    │
│ Barras                      │ Barras                        │
├─────────────────────────────┼───────────────────────────────┤
│ PESSOA × LOJA               │ PEDIDOS POR CLIENTE           │
│ Barras                      │ Barras                        │
└─────────────────────────────┴───────────────────────────────┘
```

### KPIs

-   Clientes cadastrados
-   Clientes que compraram
-   Pedidos
-   Faturamento
-   Ticket médio

### Top 10 clientes

``` text
Métrica = SUM(LineTotal)
Agrupamento = Cliente
Ordenação = DESC
Limite = 10
```

**Visualização:** barras horizontais.

### Clientes por território

``` text
Métrica = COUNT(DISTINCT CustomerID)
Agrupamento = SalesTerritory
```

**Visualização:** barras.

### Faturamento por território

``` text
Métrica = SUM(LineTotal)
Agrupamento = SalesTerritory
```

**Visualização:** barras.

### Pessoa × Loja

Comparar o faturamento associado a clientes pessoa e clientes loja.

**Visualização:** barras ou colunas.

------------------------------------------------------------------------

# 8. Etapa 5 --- Aba Vendedores

## Objetivo

Comparar o desempenho dos vendedores por faturamento, pedidos, ticket
médio e participação na receita.

## Organização

``` text
┌─────────────────────────────────────────────────────────────┐
│                  DASHBOARD — VENDEDORES                    │
├─────────────────────────────────────────────────────────────┤
│ Filtros: Ano | Mês | Território | Vendedor                  │
├──────────────┬──────────────┬──────────────┬────────────────┤
│ Vendedores   │    Pedidos   │ Faturamento  │ Ticket médio   │
├──────────────┴──────────────┴──────────────┴────────────────┤
│                 RANKING DE VENDEDORES                      │
│                    Gráfico de barras                       │
├─────────────────────────────┬───────────────────────────────┤
│ FATURAMENTO POR TERRITÓRIO  │ PEDIDOS POR VENDEDOR          │
│ Barras                      │ Barras                        │
├─────────────────────────────┼───────────────────────────────┤
│ TICKET MÉDIO POR VENDEDOR   │ PARTICIPAÇÃO NA RECEITA       │
│ Barras                      │ Barras                        │
└─────────────────────────────┴───────────────────────────────┘
```

### KPIs

-   Número de vendedores
-   Pedidos
-   Faturamento
-   Ticket médio
-   Participação na receita
-   Percentual de vendas atribuídas

### Ranking de vendedores

``` text
Métrica = SUM(LineTotal)
Agrupamento = Vendedor
Ordenação = DESC
```

**Visualização:** barras horizontais.

Também deverá existir uma tabela:

  ----------------------------------------------------------------------------
       Ranking Vendedor     Faturamento      Pedidos Ticket médio   \% Receita
  ------------ ---------- ------------- ------------ ------------ ------------
             1 ...                  ...          ...          ...          ...

             2 ...                  ...          ...          ...          ...

             3 ...                  ...          ...          ...          ...
  ----------------------------------------------------------------------------

### Faturamento por território

``` text
Métrica = SUM(LineTotal)
Agrupamento = Território
```

### Pedidos por vendedor

``` text
Métrica = COUNT(DISTINCT SalesOrderID)
Agrupamento = Vendedor
```

### Participação na receita

``` text
Faturamento do vendedor
/
Faturamento total × 100
```

### Vendas sem vendedor

Deverá ser possível identificar pedidos em que `SalesPersonID` não
esteja preenchido.

------------------------------------------------------------------------

# 9. Etapa 6 --- Filtros e interatividade

Os filtros deverão ser específicos por área.

## Vendas

-   Ano
-   Mês
-   Território
-   Categoria
-   Subcategoria

## Produtos

-   Categoria
-   Subcategoria
-   Produto

## Clientes

-   Território
-   País
-   Estado
-   Tipo de cliente

## Vendedores

-   Ano
-   Mês
-   Território
-   Vendedor

Quando possível, os filtros deverão atualizar simultaneamente os KPIs,
tabelas e gráficos da respectiva aba.

------------------------------------------------------------------------

# 10. Regras de apresentação

## Valores monetários

Usar formato consistente, por exemplo:

``` text
R$ 1.234.567,89
```

Para grandes valores, poderá ser utilizada representação abreviada:

``` text
R$ 1,2 mi
R$ 845 mil
```

## Percentuais

Exemplo:

``` text
18,5%
```

## Rankings

Ordenar do maior para o menor quando a métrica representar desempenho
positivo.

## Top 10

As visualizações Top 10 deverão respeitar os filtros selecionados antes
de determinar os dez maiores resultados.

## Análise temporal

Para vendas, a referência principal deverá ser
`SalesOrderHeader.OrderDate`.

Para análises logísticas, poderão ser utilizados:

-   `OrderDate`
-   `DueDate`
-   `ShipDate`

------------------------------------------------------------------------

# 12. Indicadores para evolução futura

## Vendas

-   Crescimento mensal;
-   Crescimento anual;
-   Receita acumulada;
-   Média móvel;
-   Receita com e sem promoção.

## Produtos

-   Margem bruta;
-   Custo do produto;
-   Produtos sem vendas;
-   Produtos em promoção;
-   Evolução de preço.

## Clientes

-   Clientes novos;
-   Clientes recorrentes;
-   Clientes sem compra recente;
-   Concentração da receita;
-   Receita média por cliente.

## Vendedores

-   Evolução mensal;
-   Crescimento de vendas;
-   Ranking por pedidos;
-   Ranking por ticket médio;
-   Meta versus realizado, caso metas sejam disponibilizadas.

## Operação

-   Tempo médio entre pedido e envio;
-   Pedidos enviados no prazo;
-   Pedidos atrasados;
-   Frete médio;
-   Performance por método de envio.

------------------------------------------------------------------------

# 13. Critérios de aceite

### CA01 --- Estrutura

Ao abrir `Relatório_Operacional.xlsx`, o usuário deverá encontrar:

-   Vendas;
-   Produtos;
-   Clientes;
-   Vendedores.

### CA02 --- Vendas

A aba Vendas deverá apresentar os principais KPIs comerciais e a
evolução do faturamento.

### CA03 --- Produtos

A aba Produtos deverá permitir identificar categorias e produtos de
maior faturamento e volume.

### CA04 --- Clientes

A aba Clientes deverá permitir identificar os principais clientes e a
distribuição das vendas por território e tipo de cliente.

### CA05 --- Vendedores

A aba Vendedores deverá permitir comparar vendedores por faturamento,
pedidos e ticket médio.

### CA06 --- Filtros

Ao alterar um filtro, os indicadores e visualizações correspondentes
deverão refletir o novo contexto.

### CA07 --- Consistência

Os KPIs deverão ser compatíveis com os dados transacionais.

Exemplo:

``` text
Faturamento =
SUM(SalesOrderDetail.LineTotal)
```

considerando os filtros aplicados.

------------------------------------------------------------------------
