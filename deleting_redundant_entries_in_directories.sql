-- Removal from a number of directories of records that do not have links in database tables
use work;
GO
--!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!СМ. переменные @rejim, @spr, @data_svertki
-- надо выставить дату свертки @data_svertki (нужна для спр-ка ТМЦ). Для удаления объектов режим (@rejim) должен быть "Удаление"
--в @spr - справочники, в которых надо удалять ненужные элементы
--будут удалены подчиненные спр-ки и периодические ревизиты основного спр-ка и подчиненных

declare @data_svertki varchar(10);
set @data_svertki='20201231';
declare @rejim varchar(10);
set @rejim='Тест';
declare @spr varchar(150);
set @spr= 'vid_obj in (''Пользователи'',''Инвестиции'',''МестаХранения'',''НеоборотныеАктивы'',''ТМЦ'')';
declare @prist varchar(10);
declare @prist1 varchar(25);
if @rejim='Тест' 
	begin
		set @prist=' SELECT * '
		set @prist1=' SELECT distinct * '
	end
else
	begin
		set @prist=' DELETE '
		set @prist1=@prist
	end
declare @StringSQL varchar(8000);
declare @StringSQL_ varchar(8000);
declare @StringSQL__ varchar(8000);
declare @StringSQL1 varchar(1000);
declare @StringSQL2 varchar(1000);
declare @vid varchar(20);
declare @vid2 varchar(20);
declare @dob varchar(100);
declare @dobTMC varchar(1000);
declare @obj varchar(20);
declare @obj2 varchar(20);
declare @rekv varchar(20);
declare @nom_circle int;
declare @nom_circle_ int;
declare @tip_obj varchar(20);
declare @kvo_yr2 int;
declare @dob2 varchar(100);
declare @dob2_ varchar(100);
declare @vid_36 varchar(10);
declare @vid_36_ varchar(10);
declare @vid_362 varchar(10);
declare @vid_rekv varchar(20);
declare @tip_rekv varchar(20);
declare @period int;
declare @period2 int;


--сначала таблицу с реквизитами неопред. типа (вообще или справочник непоределенного вида)
set @StringSQL ='';
if object_id(N'tempdb..#ft_neopr',N'U') IS NOT NULL
DROP TABLE #ft_neopr;
--объявляем курсор с ревизитами неопреленного типа
DECLARE user_cursor CURSOR FOR SELECT (RTRIM(prist_obj)+RTRIM(id_obj)) AS obj, 
	(RTRIM(prist_rekv)+RTRIM(id_rekv)) AS rekv, tip_rekv  from metad where (tip_rekv='Неопределенный')  or (tip_rekv='Справочник' and vid_rekv='')

	OPEN user_cursor;  
	set @StringSQL ='';
	SET @nom_circle = 1;
	set @StringSQL_='';
	FETCH NEXT FROM user_cursor  
	INTO @obj, @rekv,@tip_rekv; 
	-- делаем запросы по всем таблицам и реквизитам, у которых есть неопр. вид 
	--с целью получения 36-ричных значений видов справочников. Загрузим их во врем. таблицу.
	-- будет видно в какой таблице-реквизите есть элементы какого вида справочника
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		if @nom_circle <>1 
			SET @StringSQL =@StringSQL+'
			UNION ALL  '
		ELSE 
			set @StringSQL =@StringSQL;
			IF len(@StringSQL) > 7800 
				begin
				set @StringSQL_=@StringSQL
				set @StringSQL=''
				end
			else 
				set @StringSQL =@StringSQL;
			If @tip_rekv='Неопределенный'
				set @StringSQL =@StringSQL+'SELECT distinct SUBSTRING('+@rekv+',3,4) AS vid_36,'''+@obj+''' as obj,'''+@rekv+''' as rekv FROM '+@obj+' where LEFT('+@rekv+',2)=''B1''' 
			else
				set @StringSQL =@StringSQL+'SELECT distinct LEFT('+@rekv+',4) AS vid_36, '''+@obj+''' as obj,'''+@rekv+''' as rekv FROM '+@obj+' ' ;
		SET @nom_circle = @nom_circle +1;  
		FETCH NEXT FROM user_cursor  
		INTO @obj, @rekv,@tip_rekv;
	END  
	print('Реквизиты неопределенного типа');
	print 'INSERT #ft_neopr Select distinct yy.vid_36,yy.obj, yy.rekv from (' ;
	print @StringSQL_;
	print @StringSQL+')  yy order by yy.vid_36,yy.obj, yy.rekv ';
	CREATE TABLE #ft_neopr (vid_36 CHAR(4),obj varchar(10),rekv varchar(10));
	exec('INSERT #ft_neopr Select distinct yy.vid_36,yy.obj, yy.rekv from ('+@StringSQL_+@StringSQL+')  yy order by yy.vid_36,yy.obj, yy.rekv ');
	CREATE CLUSTERED INDEX main ON #ft_neopr(vid_36);
	CLOSE user_cursor; 
	DEALLOCATE user_cursor;  
	--select * from #ft_neopr
--теперь основная часть
--запрос по нужным справочникам. 
set @StringSQL = 'DECLARE user_cursor2 CURSOR FOR SELECT distinct md.vid_obj, (RTRIM(md.prist_obj)+RTRIM(md.id_obj)) AS obj
	,md.kvo_yr,md.vid_36
	,isnull(md1.period,0) from metad md
	left join (select distinct (RTRIM(md.prist_obj)+RTRIM(md.id_obj)) AS obj, period from metad md 
	where period=1) md1 on md1.obj=(RTRIM(md.prist_obj)+RTRIM(md.id_obj))
	where '+@spr+' and tip_obj<>''ВидСубконто'' 
	';
print @StringSQL;
exec(@StringSQL);
--Список обходим. Ненужные элементы каждого справочника будем удалять. И подчиненые справочники, и период. реквизиты спр-в и подч-х спр-в

OPEN user_cursor2; 
FETCH NEXT FROM user_cursor2  
INTO @vid2,@obj2,@kvo_yr2,@vid_362,@period2 ; 
WHILE @@FETCH_STATUS = 0  
BEGIN  
	set @vid=''''+@vid2+'''';
	set @vid_36=@vid_362;
	print @vid;
	--print @vid_362;
	--print @vid_36;
	if @vid='''Пользователи''' set @dob = '
	UNION ALL  SELECT distinct SP1135 AS ID FROM _1SJOURN ' ELSE set @dob='';
	if @vid='''ТМЦ''' 
		Begin
			if object_id(N'tempdb..#ft_TMC',N'U') IS NOT NULL
			DROP TABLE #ft_TMC;

			set @dobTMC=' INSERT #FT_TMC
			SELECT sc289.ID
			FROM sc289 sc289 WITH (NOLOCK) 
			JOIN ( SELECT sc15123.PARENTEXT, sc15123.sp15126,sc15123.sp15127, 1 Odin 
			,(CASE WHEN (sc15123.sp15126=''     0   '') OR (sc15123.sp15127=''     AOTS'' AND sc15123.sp15126=''     AOTS'')
			 THEN 1 ELSE 0 END) Odin1 
			FROM sc15123 sc15123 WITH (NOLOCK)
			) Zapr ON  Zapr.PARENTEXT=sc289.ID
			WHERE sc289.sp11357 <= '''+@data_svertki+''' 
			GROUP BY sc289.ID
			HAVING (SUM(Zapr.Odin))= (SUM(Zapr.Odin1)) 
			union all
			SELECT sc289.ID 
			FROM sc289 sc289 WITH (NOLOCK) 
			left join sc289 sc289_1 on sc289_1.id=sc289.Parentid
			left join sc289 sc289_2 on sc289_1.Parentid=sc289_2.id
			where sc289.Parentid=''   1PT   '' or sc289_1.Parentid=''   1PT   '' or sc289_2.Parentid=''   1PT   '' 
			and sc289.sp11357 <= '''+@data_svertki+'''  ' 
			CREATE TABLE #ft_TMC (ID CHAR(9) );
			CREATE CLUSTERED INDEX main ON #ft_TMC(ID);
			print @dobTMC;
			exec(@dobTMC);
			set @dobTMC='
			join (SELECT ID FROM #FT_TMC) zzz ON zzz.id=rr2.id ' ;
		end
	ELSE set @dobTMC='';
	if @kvo_yr2>1 
		begin 
			set @dob2 = '
			WHERE '+@obj2+'.ISFOLDER=2 ' 
			set @dob2_ = ' AND ISFOLDER=2 ' 
		end
	ELSE 
		begin
			set @dob2=''	
			set @dob2_='' 
		end
	set @StringSQL ='';
	set @StringSQL_='';
	set @StringSQL1 ='';
	--запрос по всем объектам, у реквизитов которого есть такой справочник. 
	set @StringSQL =@StringSQL+'DECLARE user_cursor CURSOR FOR  ';
	set @StringSQL =@StringSQL+'SELECT (RTRIM(md.prist_obj)+RTRIM(md.id_obj)) AS obj, 
	(RTRIM(md.prist_rekv)+RTRIM(md.id_rekv)) AS rekv, md.tip_obj,md.tip_rekv,md.vid_rekv 
	,isnull(FT.vid_36,'''') as  vid_36
	from metad md 
	left join #ft_neopr FT ON FT.obj=(RTRIM(md.prist_obj)+RTRIM(md.id_obj)) and FT.rekv=(RTRIM(md.prist_rekv)+RTRIM(md.id_rekv))
	and FT.vid_36='''+@vid_36+'''
	where (md.tip_rekv=''Справочник'' and md.vid_rekv='+@vid +')
	or (md.tip_rekv=''Справочник'' and md.vid_rekv='''') or (md.tip_rekv=''Неопределенный'')
	order by md.vid_rekv, md.tip_obj desc ';
	print @StringSQL;
	exec(@StringSQL);
	OPEN user_cursor;  
	set @StringSQL ='';
	SET @nom_circle = 1;
	SET @nom_circle_ = 0;
	set @StringSQL__='';
	FETCH NEXT FROM user_cursor  
	INTO @obj, @rekv,@tip_obj,@tip_rekv,@vid_rekv,@vid_36_; 

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
	--Формируем тест запроса по идам, которых нет в ссылках реквизитов объектов и создаем фильтр по ним. Их можно удалить
		if @nom_circle <>1 
			If RTRIM(@vid_rekv)<>''
				SET @StringSQL =@StringSQL+'
				UNION ALL  '
			else
			if @vid_36_=''
			set @StringSQL =@StringSQL;
			else 
				SET @StringSQL =@StringSQL+'
				UNION ALL  '
		ELSE 
			set @StringSQL =@StringSQL;
		if @tip_obj<>'ВидСубконто'
			If RTRIM(@vid_rekv)<>''
				IF @nom_circle_ = 0 
					begin
						set @StringSQL__=@StringSQL
						set @StringSQL=''
						set @StringSQL =@StringSQL+'SELECT distinct '+@rekv+' AS ID FROM '+@obj
						set @nom_circle_=1
					end
				else
					set @StringSQL =@StringSQL+'SELECT distinct '+@rekv+' AS ID FROM '+@obj
			else
				begin
					if @vid_36_=''
						GOTO Label_;
					if @tip_rekv<>'Неопределенный'
						set @StringSQL =@StringSQL+'SELECT distinct RIGHT('+@rekv+',9) AS ID FROM '+@obj+' where LEFT('+@rekv+',4)='''+@vid_36+'''' 
					else
						set @StringSQL =@StringSQL+'SELECT distinct SUBSTRING('+@rekv+',7,9) AS ID FROM '+@obj+' where LEFT('+@rekv+',2)=''B1'' ';
				end
		else
			--по хорошему было бы проверить вид реквизита субконто в метаданных. Здесь считается, 
			--что он всегда определен для справочников. Поэтому используется 'left(...)'. 
			--Субконто "Заказы" имеет тип документа неопределенного вида. Для него надо было бы использовать 'Right(...)'
			set @StringSQL_ =@StringSQL_+
			'SELECT Distinct zz.IDSPR FROM (
			SELECT Distinct left(SC0,9) AS IDSPR 
			FROM _1SBKTTL WITH (NOLOCK)
			WHERE VSC0='+@obj+'
			UNION ALL
			SELECT Distinct left(SC1,9) AS IDSPR 
			FROM _1SBKTTL WITH (NOLOCK)
			WHERE VSC1='+@obj+'
			UNION ALL
			SELECT Distinct left(SC2,9) AS IDSPR 
			FROM _1SBKTTL WITH (NOLOCK)
			WHERE VSC2='+@obj+'

			UNION ALL
			SELECT Distinct left(KTSC0,9) AS IDSPR 
			FROM _1SENTRY WITH (NOLOCK)
			WHERE VKTSC0='+@obj+'
			UNION ALL
			SELECT Distinct left(DTSC0,9) AS IDSPR 
			FROM _1SENTRY WITH (NOLOCK)
			WHERE VDTSC0='+@obj+'
			UNION ALL
			SELECT Distinct left(KTSC1,9) AS IDSPR 
			FROM _1SENTRY WITH (NOLOCK)
			WHERE VKTSC1='+@obj+'
			UNION ALL
			SELECT Distinct left(DTSC1,9) AS IDSPR 
			FROM _1SENTRY WITH (NOLOCK)
			WHERE VDTSC1='+@obj+'
			UNION ALL
			SELECT Distinct left(KTSC2,9) AS IDSPR 
			FROM _1SENTRY WITH (NOLOCK)
			WHERE VKTSC2='+@obj+'
			UNION ALL
			SELECT Distinct left(DTSC2,9) AS IDSPR 
			FROM _1SENTRY WITH (NOLOCK)
			WHERE VDTSC2='+@obj+'
			) zz'		;
		SET @nom_circle = @nom_circle +1;  
Label_:
		FETCH NEXT FROM user_cursor  
		INTO @obj, @rekv,@tip_obj,@tip_rekv,@vid_rekv,@vid_36_;
	END  
	-- запрос, вставка во врем. таблицу идов, не имеющих ссылок.   
	if object_id(N'tempdb..#ft',N'U') IS NOT NULL
	DROP TABLE #ft;
	CREATE TABLE #ft (ID CHAR(9) );
	print 'INSERT #ft SELECT rr2.ID FROM ( SELECT '+@obj2+'.ID, '+@obj2+'.CODE, rr1.ID AS ID2 FROM '+@obj2+' '+@obj2+'
	LEFT JOIN  ( SELECT distinct ID FROM ( '+@StringSQL__+'';
	print ''+@StringSQL+@StringSQL_+@dob+' ) rr ) rr1 ON rr1.ID = '+@obj2+'.ID ) rr2 '+@dobTMC+'
	WHERE ISNULL(rr2.ID2,'''')=''''  ';
	exec ('INSERT #ft SELECT rr2.ID FROM ( SELECT '+@obj2+'.ID, '+@obj2+'.CODE, rr1.ID AS ID2 FROM '+@obj2+' '+@obj2+'
	LEFT JOIN  ( SELECT distinct ID FROM ( '+@StringSQL__+@StringSQL+@StringSQL_+@dob+' ) rr ) rr1 ON rr1.ID = '+@obj2+'.ID ) rr2 '+@dobTMC+'
	WHERE ISNULL(rr2.ID2,'''')=''''  ');
	CREATE CLUSTERED INDEX main ON #ft(ID);

	CLOSE user_cursor; 
	DEALLOCATE user_cursor;  
	--сначала удаляем подчиненные справочники
	set @StringSQL1 =@StringSQL1+'DECLARE user_cursor CURSOR FOR  ';
	set @StringSQL1 =@StringSQL1+'SELECT distinct (RTRIM(md.prist_obj)+RTRIM(md.id_obj)) AS obj, isnull(md1.period,0) from metad md
	left join (select distinct (RTRIM(md.prist_obj)+RTRIM(md.id_obj)) AS obj, period from metad md 
	where period=1) md1 on md1.obj=(RTRIM(md.prist_obj)+RTRIM(md.id_obj))
	where md.vid_obJ_parent='+@vid ;
	print @StringSQL1;
	exec(@StringSQL1);

	OPEN user_cursor; 
	FETCH NEXT FROM user_cursor  
	INTO @obj,@period; 

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
	--удаляем элементы каждого подчиненного справочника
	--сначала период. реквизиты
		if @period=1 
			begin
				set @StringSQL1=@prist+' from _1SCONST where OBJID in (SELECT distinct id FROM '+@obj+' '+@obj+' 
				WHERE '+@obj+'.PARENTEXT IN ( SELECT ID FROM #ft)) 
				and ID in (select id_rekv from metad where prist_obj+rtrim(convert(char,id_obj))='''+@obj+''' and period=1)';
				print @StringSQL1;
				exec(@StringSQL1);
			end	
	--теперь подч. спр-к
		set @StringSQL1 ='';
		set @StringSQL1 =@StringSQL1+@prist1+'  FROM '+@obj+'  WHERE '+@obj+'.PARENTEXT IN ( SELECT ID FROM #ft) ';
		print @StringSQL1;
		exec(@StringSQL1);
		FETCH NEXT FROM user_cursor  
		INTO @obj,@period;
	END  
	--удаляем элементы спр-ка, которые есть в фильтре
	--сначала период. реквизиты
	--select id from #ft
	if @period2=1
		begin
			set @StringSQL1= @prist+' from _1SCONST 
			where OBJID in (select FT.ID from #ft FT
			LEFT JOIN '+@obj2+' '+@obj2+' ON '+@obj2+'.ID=FT.ID '+@dob2+') 
			and	ID in(select id_rekv from metad where prist_obj+rtrim(convert(char,id_obj))='''+@obj2+''' and period=1)';
			print @StringSQL1;
			exec(@StringSQL1);
		end
	--теперь осн. спр-к	
	set @StringSQL1=@prist+' FROM '+@obj2+' 
	WHERE ID IN (SELECT ID FROM #ft)'+@dob2_;
	print @StringSQL1;
	exec(@StringSQL1);
	DROP TABLE #ft
	if @vid='''ТМЦ'''
	begin 
		--удаляем пустые группы спр-ка "ТМЦ"
		DROP TABLE #ft_TMC
		set @StringSQL1=@prist+' from SC289 where id IN (
		select e.id from SC289 e WITH (NOLOCK)
		LEFT JOIN (SELECT distinct a.PARENTID from SC289 a WITH (NOLOCK)) c ON c.PARENTID=e.ID
		WHERE e.isfolder=1 and isnull(c.PARENTID,'''')='''') '
		print @StringSQL1;
		exec(@StringSQL1);
	end
	CLOSE user_cursor; 
	DEALLOCATE user_cursor;  
	FETCH NEXT FROM user_cursor2  
	INTO @vid2,@obj2,@kvo_yr2,@vid_362,@period2
END  
CLOSE user_cursor2; 
DEALLOCATE user_cursor2;  
DROP TABLE #ft_neopr
GO

