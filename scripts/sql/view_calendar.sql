ALTER VIEW [analytics].[calendar] AS 

with year_table as (
	select 
		value as year,
		iif(day(eomonth(cast(concat(value, '-', '02', '-', '01') as date))) = '29', 1, 0) as leap_year
	from generate_series(2000, 2050, 1)
),

month_table as (
	select 
		value as month,
		case 
			when value = 1 then 'Janeiro'
			when value = 2 then 'Fevereiro'
			when value = 3 then 'Março'
			when value = 4 then 'Abril'
			when value = 5 then 'Maio'
			when value = 6 then 'Junho'
			when value = 7 then 'Julho'
			when value = 8 then 'Agosto'
			when value = 9 then 'Setembro'
			when value = 10 then 'Outubro'
			when value = 11 then 'Novembro'
			when value = 12 then 'Dezembro'
		end as month_name,
		case
			when value in (1, 2, 3) then 1
			when value in (4, 5, 6) then 2
			when value in (7, 8, 9) then 3
			when value in (10, 11, 12) then 4
		end as quarter
	from generate_series(1, 12, 1)
),

base_dates as (
	select 
		cast("date" as date) as "date",
		year, leap_year, month, month_name, quarter, day,
		iif(try_convert(date, "date", 23) is not null, 1, 0) as date_is_valid
	from (
		select
			concat(year, '-', month, '-', day) as "date",
			year_table.*, month_table.*, day
		from year_table
		cross join month_table
		cross join (select value as day from generate_series(1, 31, 1)) day_table
	) all_dates
),

holiday_table as (
	select
		month(holiday_date) as holiday_month,
		day(holiday_date) as holiday_day,
		holiday_name
	from (
		values
			(cast('2026-01-01' as date), 'Confraternização Universal'),
			(cast('2026-04-03' as date), 'Paixão de Cristo'),
			(cast('2026-04-21' as date), 'Tiradentes'),
			(cast('2026-05-01' as date), 'Dia Mundial do Trabalho'),
			(cast('2026-09-07' as date), 'Independência do Brasil'),
			(cast('2026-10-12' as date), 'Nossa Senhora Aparecida'),
			(cast('2026-11-02' as date), 'Finados'),
			(cast('2026-11-15' as date), 'Proclamação da República'),
			(cast('2026-11-20' as date), 'Dia Nacional de Zumbi e da Consciência Negra'),
			(cast('2026-12-25' as date), 'Natal')
	) as holidays(holiday_date, holiday_name)
)

select
	"date",
	year,
	leap_year,
	month,
	month_name,
	substring(month_name, 1, 3) as month_label,
	concat(substring(month_name, 1, 3), '/', year) as month_year_label,
	datefromparts(year("date"), month(month), 1 ) as first_month_day,
	eomonth("date") as last_month_day,
	day,
	datepart(weekday, "date") as day_of_week,
	case
		when datepart(weekday, "date") = 1 then 'Domingo'
		when datepart(weekday, "date") = 2 then 'Segunda'
		when datepart(weekday, "date") = 3 then 'Terça'
		when datepart(weekday, "date") = 4 then 'Quarta'
		when datepart(weekday, "date") = 5 then 'Quinta'
		when datepart(weekday, "date") = 6 then 'Sexta'
		when datepart(weekday, "date") = 7 then 'Sábado'
	end as day_name,
	iif(datepart(weekday, "date") in (1, 7), 1, 0) as is_weekend,
	iif(ht.holiday_name is not null, 1, 0) as is_holiday,
	iif(ht.holiday_name is not null, ht.holiday_name, '-') as holiday_name,
	quarter,
	case
		when quarter = 1 then 'T1'
		when quarter = 2 then 'T2'
		when quarter = 3 then 'T3'
		when quarter = 4 then 'T4'
	end as quarter_label,
	case
		when quarter = 1 then concat(year, '-', '01', '-', '01')
		when quarter = 2 then concat(year, '-', '04', '-', '01')
		when quarter = 3 then concat(year, '-', '07', '-', '01')
		when quarter = 4 then concat(year, '-', '10', '-', '01')
	end as quarter_start_date,
	case
		when quarter = 1 then concat(year, '-', '03', '-', '31')
		when quarter = 2 then concat(year, '-', '06', '-', '30')
		when quarter = 3 then concat(year, '-', '09', '-', '30')
		when quarter = 4 then concat(year, '-', '12', '-', '31')
	end as quarter_end_date
from base_dates
	left join holiday_table ht
		on ht.holiday_month = month 
		and ht.holiday_day = day
where date_is_valid = 1
