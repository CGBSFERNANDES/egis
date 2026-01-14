use egisadmin
go


select identity(int,1,1) as , * into #relatributo from relatorio_atributo


declare @cd_controle int


declare @sql nvarchar(max)                  = ''
declare @nm_atributo_relatorio varchar(200) = ''

while exists ( select top 1 cd_controle from #relAtributo )
begin
  select top 1
     @cd_controle           = isnull(cd_controle,0),
	 @nm_atributo_relatorio = isnull(nm_atributo_relatorio,'')

 from
    #RelAtributo

 set @sql = @sql 
            + 
            case when @sql<>'' then ', ' else cast('' as varchar(1)) end
			+


 order by
   cd_controle 

 
  
 



 delete from #relAtributo
 where
   cd_controle = @cd_controle



end
