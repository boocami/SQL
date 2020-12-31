--PROBLEMA1--------
create table tbl_regautornac(nomautor varchar(50),nac int)

create procedure pa_InsertaAutorLibro
@autorXML ntext, @libroXML ntext
as
declare @iDoc int
declare @iDoc2 int
declare @codautor int
declare @nomautor varchar(50)
declare @fechanac date
declare @nacionalidad int
declare @codlib int
declare @nomlib varchar(50)

execute sp_xml_preparedocument @iDoc OUTPUT, @autorXML
declare cur1 cursor for
select * from OPENXML(@iDoc, '/Autores/Autor',2)
with (
		codautor int,
		nombre varchar(50),
		fechanac date,
		nacionalidad int
	 )
	 open cur1
	 fetch cur1 into @codautor,@nomautor,@fechanac,@nacionalidad
	 while(@@FETCH_STATUS=0)
	 begin
		if not exists(select nac.codNac from tbl_nacionalidad nac where nac.codnac=@nacionalidad)
		begin
			print 'nacionalidad '+cast(@nacionalidad as varchar(10))+' no existe'
			if not exists(select nomautor from tbl_regautornac where nomautor=@nomautor)
			begin
				insert into tbl_regautornac values (@nomautor,@nacionalidad)
			end
		end
		
		if exists(select a.nomautor from tbl_autor a where a.nomautor=@nomautor)
		begin
			print @nomautor+'ya esta registrado'
		end
		else
		begin
			insert into tbl_autor values(@codautor,@nomautor)
			print @nomautor+' registrado correctamente en tbl_autor'
		end

		if exists(select an.codautor from tbl_autonac an where an.codautor=@codautor)
		begin
			print @nomautor+' ya esta registado en tbl_autonac'	
		end
		else
		begin
			
			if exists(select codnac from tbl_Nacionalidad where CodNac=@nacionalidad)
			begin
				insert into tbl_autonac values(@codautor,@nacionalidad)
				print @nomautor+' registrado correctamente en tbl_autonac'
			end

		end
			
	 fetch cur1 into @codautor,@nomautor,@fechanac,@nacionalidad	
	 end
	 close cur1
	 deallocate cur1
execute sp_xml_removedocument @iDoc

execute sp_xml_preparedocument @iDoc2 OUTPUT, @libroXML
	declare cur2 cursor for
	select * from OPENXML(@iDoc2, '/Libros/Libro',2)
	with (
			codigo int,
			nombre varchar(50),
			autor int
			)
			open cur2
			fetch cur2 into @codlib,@nomlib,@codautor
			while(@@FETCH_STATUS=0)
			begin
				if exists (select codlib from tbl_Libro where CodLib=@codlib)
				begin
					print 'El libro '+@nomlib+' ya se encuentra registrado'
				end
				else
				begin
					insert into tbl_Libro values(@codlib,@nomlib)
					print 'El libro '+@nomlib+' Se ha registrado con exito'
				end
				if exists(select codautor,codlib from tbl_AutorLib where codautor=@codautor and CodLib=@codlib)
				begin
					print 'El libro '+@nomlib+' ya esta registrado en tbl_autorlib'
				end
				else
				begin
					if not exists(select codautor from tbl_Autor where CodAutor=@codautor)
					begin
						print 'codigo autor '+cast(@codautor as varchar(10))+' no esta registrado'
					end
					else
					begin
						insert into tbl_autorlib values(@codautor,@codlib)
						print 'Libro '+@nomlib+' y codigo autor '+cast(@codautor as varchar(10))+' se ingresaron correctamente a tbl_autorlib'
					end
				end
				fetch cur2 into @codlib,@nomlib,@codautor
			end
			close cur2
			deallocate cur2
			execute sp_xml_removedocument @iDoc2




pa_InsertaAutorLibro '<Autores>
	<Autor>
		<codautor>1</codautor>
		<nombre>Rimbaud</nombre>
		<fechanac>12-10-1890</fechanac>
		<nacionalidad>1</nacionalidad>
	</Autor>
	<Autor>
		<codautor>2</codautor>
		<nombre>Baudelarie</nombre>
		<fechanac>10-09-1880</fechanac>
		<nacionalidad>1</nacionalidad>
	</Autor>
	<Autor>
		<codautor>3</codautor>
		<nombre>Mallarme</nombre>
		<fechanac>10-09-1870</fechanac>
		<nacionalidad>1</nacionalidad>
	</Autor>
	<Autor>
		<codautor>4</codautor>
		<nombre>Oscar Wilde</nombre>
		<fechanac>09-09-1920</fechanac>
		<nacionalidad>1</nacionalidad>
	</Autor>			
</Autores>','<Libros>
	<Libro>
		<codigo>1</codigo>
		<nombre>Una temporada en el infierno</nombre>
		<autor>1</autor>
	</Libro>
	<Libro>
		<codigo>2</codigo>
		<nombre>Iluminaciones</nombre>
		<autor>1</autor>
	</Libro>	
	<Libro>
		<codigo>3</codigo>
		<nombre>El Splend de Paris</nombre>
		<autor>2</autor>
	</Libro>	
</Libros>'



select * from tbl_Autor;
select * from tbl_regautornac;
select * from tbl_libro;
select * from tbl_autorlib;

---PROBLEMA 2----

create procedure pa_Insertanacionalidad
@nacXML ntext,@autorXML ntext
as
declare @iDoc int
declare @iDoc2 int
declare @codautor int
declare @nomautor varchar(50)
declare @fechanac date
declare @codnac int
declare @nomnac varchar(50)
declare @nacautor int

execute sp_xml_preparedocument @iDoc OUTPUT, @nacXML
declare cur1 cursor for
select * from OPENXML(@iDoc, '/Nacionalidades/Nacionalidad',2)
with (
		codigo int,
		nombre varchar(50)
	 )
	 open cur1
	 fetch cur1 into @codnac,@nomnac
	 while(@@FETCH_STATUS=0)
	 begin
		if exists(select codnac from tbl_Nacionalidad where CodNac=@codnac)
		begin
			print 'La nacionalidad '+@nomnac+' ya esta registrada'
		end
		else
		begin
			insert into tbl_Nacionalidad values(@codnac,@nomnac)
			print 'La nacionalidad '+@nomnac+' se ha registrado exitosamente'
		end
		
		execute sp_xml_preparedocument @iDoc2 OUTPUT, @autorXML
		declare cur2 cursor for
		select * from OPENXML(@iDoc2, '/Autores/Autor',2)
		with (
				codautor int,
				nombre varchar(50),
				fechanac date,
				nacionalidad int
			 )
			 open cur2
			 fetch cur2 into @codautor,@nomautor,@fechanac,@nacautor
			 while(@@FETCH_STATUS=0)
			 begin
				 if (@nacautor=@codnac)
				 begin
					if exists(select codautor,codnac from tbl_AutoNac where CodAutor=@codautor and CodNac=@codnac)
					begin
						print 'ya se encuentra el autor '+@nomautor+' registrado en tbl_autonac'
					end
					else
					begin
						insert into tbl_AutoNac values(@codautor,@codnac)
						print'El autor '+@nomautor+' Se registro corectamente en tbl_autonac'
					end
				 end
				 fetch cur2 into @codautor,@nomautor,@fechanac,@nacautor
			 end
			 close cur2
			 deallocate cur2
			 execute sp_xml_removedocument @iDoc2


		fetch cur1 into @codnac,@nomnac
	 end
	 close cur1
	 deallocate cur1
	 execute sp_xml_removedocument @iDoc

	 pa_Insertanacionalidad '<Nacionalidades>
	<Nacionalidad>
		<codigo>1</codigo>
		<nombre>Francesa</nombre>
	</Nacionalidad>
	<Nacionalidad>
		<codigo>2</codigo>
		<nombre>Chilena</nombre>
	</Nacionalidad>
	<Nacionalidad>
		<codigo>3</codigo>
		<nombre>Belga</nombre>
	</Nacionalidad>		
</Nacionalidades>','<Autores>
	<Autor>
		<codautor>1</codautor>
		<nombre>Rimbaud</nombre>
		<fechanac>12-10-1890</fechanac>
		<nacionalidad>1</nacionalidad>
	</Autor>
	<Autor>
		<codautor>2</codautor>
		<nombre>Baudelarie</nombre>
		<fechanac>10-09-1880</fechanac>
		<nacionalidad>1</nacionalidad>
	</Autor>
	<Autor>
		<codautor>3</codautor>
		<nombre>Mallarme</nombre>
		<fechanac>10-09-1870</fechanac>
		<nacionalidad>1</nacionalidad>
	</Autor>
	<Autor>
		<codautor>4</codautor>
		<nombre>Oscar Wilde</nombre>
		<fechanac>09-09-1920</fechanac>
		<nacionalidad>1</nacionalidad>
	</Autor>			
</Autores>'


select * from tbl_Autor;
select * from tbl_Nacionalidad;
select * from tbl_AutoNac

--PROBLEMA 3-----
create table tbl_logautor(nomautor varchar(50), fecha datetime)

create trigger trg_ingreso on tbl_autor for insert
as
declare @autor varchar(50)
set @autor=(select nomautor from inserted)
insert into tbl_logautor values(@autor,getdate())

--PROBLEMA 4-----
create procedure borraautor
@codautor int
as
delete from tbl_AutoNac where CodAutor=@codautor
delete from tbl_AutorLib where CodAutor=@codautor
delete from tbl_Autor where CodAutor=@codautor

borraautor'1'