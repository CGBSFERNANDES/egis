IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pr_geracao_sped_fiscal_egisnet' 
	   AND 	  type = 'P')
    DROP PROCEDURE pr_geracao_sped_fiscal_egisnet

GO
-------------------------------------------------------------------------------
--sp_helptext pr_geracao_sped_fiscal_egisnet
-------------------------------------------------------------------------------
--GBS Global Business Solution Ltda                                        2025
-------------------------------------------------------------------------------
--Stored Procedure : Microsoft SQL Server 2016
--Autor(es)        : Fagner Cardoso
--
--Banco de Dados   : Egissql
--
--Objetivo         : Geração do Arquivo SPED
--
--Data             : 20.12.2025
--Alteração        : 
---------------------------------------------------------------------------------------------
create procedure  pr_geracao_sped_fiscal_egisnet
@dt_inicial datetime = '',
@dt_final   datetime = ''
as


delete from EFD_REGISTRO_0000
delete from EFD_REGISTRO_0001
delete from EFD_REGISTRO_0005
delete from EFD_REGISTRO_0015
delete from EFD_REGISTRO_0100

delete from EFD_REGISTRO_0150
exec dbo.pr_gera_efd_registro_0150  @dt_inicial, @dt_final

delete from EFD_REGISTRO_0175
exec dbo.pr_gera_efd_registro_0175  @dt_inicial, @dt_final

delete from EFD_REGISTRO_0190
exec dbo.pr_gera_efd_registro_0190  @dt_inicial, @dt_final

delete from EFD_REGISTRO_0200
exec dbo.pr_gera_efd_registro_0200  @dt_inicial, @dt_final

delete from EFD_REGISTRO_0205
delete from EFD_REGISTRO_0206
delete from EFD_REGISTRO_0220
delete from EFD_REGISTRO_0300
exec dbo.pr_gera_efd_registro_0300  @dt_inicial, @dt_final

delete from EFD_REGISTRO_0305
exec dbo.pr_gera_efd_registro_0305  @dt_inicial, @dt_final

delete from EFD_REGISTRO_0400
exec dbo.pr_gera_efd_registro_0400  @dt_inicial, @dt_final

delete from EFD_REGISTRO_0450

delete from EFD_REGISTRO_0460
exec dbo.pr_gera_efd_registro_0460  @dt_inicial, @dt_final

delete from EFD_REGISTRO_0500
exec dbo.pr_gera_efd_registro_0500  @dt_inicial, @dt_final

delete from EFD_REGISTRO_0600
exec dbo.pr_gera_efd_registro_0600  @dt_inicial, @dt_final

delete from EFD_REGISTRO_0990

delete from EFD_REGISTRO_B001

delete from EFD_REGISTRO_B990

delete from EFD_REGISTRO_C001

delete from EFD_REGISTRO_C100
exec dbo.pr_gera_efd_registro_C100  @dt_inicial, @dt_final

delete from EFD_REGISTRO_C105

delete from EFD_REGISTRO_C110

delete from EFD_REGISTRO_C111

delete from EFD_REGISTRO_C112

delete from EFD_REGISTRO_C113

delete from EFD_REGISTRO_C114

delete from EFD_REGISTRO_C115

delete from EFD_REGISTRO_C120

delete from EFD_REGISTRO_C130

delete from EFD_REGISTRO_C140

delete from EFD_REGISTRO_C141

delete from EFD_REGISTRO_C160

delete from EFD_REGISTRO_C165

delete from EFD_REGISTRO_C170
exec dbo.pr_gera_efd_registro_C170  @dt_inicial, @dt_final

delete from EFD_REGISTRO_C170_AUX
exec dbo.pr_gera_efd_registro_C170_aux  @dt_inicial, @dt_final

delete from EFD_REGISTRO_C171

delete from EFD_REGISTRO_C172

delete from EFD_REGISTRO_C173

delete from EFD_REGISTRO_C174

delete from EFD_REGISTRO_C175

delete from EFD_REGISTRO_C176

delete from EFD_REGISTRO_C177

delete from EFD_REGISTRO_C178

delete from EFD_REGISTRO_C179

delete from EFD_REGISTRO_C190
exec dbo.pr_gera_efd_registro_C190  @dt_inicial, @dt_final

delete from EFD_REGISTRO_C195
exec dbo.pr_gera_efd_registro_C195  @dt_inicial, @dt_final

delete from EFD_REGISTRO_C197
exec dbo.pr_gera_efd_registro_C197  @dt_inicial, @dt_final

delete from EFD_REGISTRO_C300

delete from EFD_REGISTRO_C310

delete from EFD_REGISTRO_C320

delete from EFD_REGISTRO_C321

delete from EFD_REGISTRO_C350

delete from EFD_REGISTRO_C370

delete from EFD_REGISTRO_C390

delete from EFD_REGISTRO_C400

delete from EFD_REGISTRO_C405

delete from EFD_REGISTRO_C410

delete from EFD_REGISTRO_C420

delete from EFD_REGISTRO_C425

delete from EFD_REGISTRO_C460

delete from EFD_REGISTRO_C470

delete from EFD_REGISTRO_C490

delete from EFD_REGISTRO_C495

delete from EFD_REGISTRO_C500
exec dbo.pr_gera_efd_registro_C500  @dt_inicial, @dt_final

delete from EFD_REGISTRO_C510
exec dbo.pr_gera_efd_registro_C510  @dt_inicial, @dt_final

delete from EFD_REGISTRO_C510_AUX
exec dbo.pr_gera_efd_registro_C510_aux  @dt_inicial, @dt_final

delete from EFD_REGISTRO_C590
exec dbo.pr_gera_efd_registro_C590  @dt_inicial, @dt_final



delete from EFD_REGISTRO_C600

delete from EFD_REGISTRO_C610

delete from EFD_REGISTRO_C690

delete from EFD_REGISTRO_C700

delete from EFD_REGISTRO_C790

delete from EFD_REGISTRO_C791

delete from EFD_REGISTRO_C990

delete from EFD_REGISTRO_D001

delete from EFD_REGISTRO_D100
exec dbo.pr_gera_efd_registro_D100  @dt_inicial, @dt_final

delete from EFD_REGISTRO_D110

delete from EFD_REGISTRO_D150

delete from EFD_REGISTRO_D160

delete from EFD_REGISTRO_D161

delete from EFD_REGISTRO_D162

delete from EFD_REGISTRO_D170

delete from EFD_REGISTRO_D180

delete from EFD_REGISTRO_D190_AUX
exec dbo.pr_gera_efd_registro_D190_aux  @dt_inicial, @dt_final

delete from EFD_REGISTRO_D190
exec dbo.pr_gera_efd_registro_D190  @dt_inicial, @dt_final

delete from EFD_REGISTRO_D300

delete from EFD_REGISTRO_D301

delete from EFD_REGISTRO_D310

delete from EFD_REGISTRO_D350

delete from EFD_REGISTRO_D355

delete from EFD_REGISTRO_D360

delete from EFD_REGISTRO_D365

delete from EFD_REGISTRO_D370

delete from EFD_REGISTRO_D390

delete from EFD_REGISTRO_D400

delete from EFD_REGISTRO_D410

delete from EFD_REGISTRO_D420

delete from EFD_REGISTRO_D500
exec dbo.pr_gera_efd_registro_D500  @dt_inicial, @dt_final

delete from EFD_REGISTRO_D510
exec dbo.pr_gera_efd_registro_D510  @dt_inicial, @dt_final

delete from EFD_REGISTRO_D510_AUX
exec dbo.pr_gera_efd_registro_D510_aux  @dt_inicial, @dt_final


delete from EFD_REGISTRO_D530

delete from EFD_REGISTRO_D590
exec dbo.pr_gera_efd_registro_D590  @dt_inicial, @dt_final

delete from EFD_REGISTRO_D600

delete from EFD_REGISTRO_D610

delete from EFD_REGISTRO_D690

delete from EFD_REGISTRO_D695

delete from EFD_REGISTRO_D696

delete from EFD_REGISTRO_D697

delete from EFD_REGISTRO_D990

delete from EFD_REGISTRO_E001

delete from EFD_REGISTRO_E100
exec dbo.pr_gera_efd_registro_E100  @dt_inicial, @dt_final

delete from EFD_REGISTRO_E110
exec dbo.pr_gera_efd_registro_E110  @dt_inicial, @dt_final

delete from EFD_REGISTRO_E111
exec dbo.pr_gera_efd_registro_E111  @dt_inicial, @dt_final

delete from EFD_REGISTRO_E112

delete from EFD_REGISTRO_E113

delete from EFD_REGISTRO_E115

delete from EFD_REGISTRO_E116
exec dbo.pr_gera_efd_registro_E116  @dt_inicial, @dt_final

delete from EFD_REGISTRO_E200

delete from EFD_REGISTRO_E210

delete from EFD_REGISTRO_E220

delete from EFD_REGISTRO_E230

delete from EFD_REGISTRO_E240

delete from EFD_REGISTRO_E250

delete from EFD_REGISTRO_E500
exec dbo.pr_gera_efd_registro_E500  @dt_inicial, @dt_final

delete from EFD_REGISTRO_E510
exec dbo.pr_gera_efd_registro_E510  @dt_inicial, @dt_final

delete from EFD_REGISTRO_E520
exec dbo.pr_gera_efd_registro_E520  @dt_inicial, @dt_final

delete from EFD_REGISTRO_E530
exec dbo.pr_gera_efd_registro_E530  @dt_inicial, @dt_final

delete from EFD_REGISTRO_E990

delete from EFD_REGISTRO_G001
exec dbo.pr_gera_efd_registro_G001  @dt_inicial, @dt_final

delete from EFD_REGISTRO_G110
exec dbo.pr_gera_efd_registro_G110  @dt_inicial, @dt_final

delete from EFD_REGISTRO_G125
exec dbo.pr_gera_efd_registro_G125  @dt_inicial, @dt_final

delete from EFD_REGISTRO_G126
exec dbo.pr_gera_efd_registro_G126  @dt_inicial, @dt_final

delete from EFD_REGISTRO_G130

delete from EFD_REGISTRO_G140

delete from EFD_REGISTRO_G990

delete from EFD_REGISTRO_H001
exec dbo.pr_gera_efd_registro_H001  @dt_inicial, @dt_final

delete from EFD_REGISTRO_H005
exec dbo.pr_gera_efd_registro_H005  @dt_inicial, @dt_final

delete from EFD_REGISTRO_H010
exec dbo.pr_gera_efd_registro_H010  @dt_inicial, @dt_final

delete from EFD_REGISTRO_H990

delete from EFD_REGISTRO_K001

delete from EFD_REGISTRO_K100
exec dbo.pr_gera_efd_registro_K100  @dt_inicial, @dt_final

delete from EFD_REGISTRO_K200
exec dbo.pr_gera_efd_registro_K200  @dt_inicial, @dt_final

delete from EFD_REGISTRO_K220

delete from EFD_REGISTRO_K230
exec dbo.pr_gera_efd_registro_K230  @dt_inicial, @dt_final

delete from EFD_REGISTRO_K235
exec dbo.pr_gera_efd_registro_K235  @dt_inicial, @dt_final

delete from EFD_REGISTRO_K250
exec dbo.pr_gera_efd_registro_K250  @dt_inicial, @dt_final

delete from EFD_REGISTRO_K255
exec dbo.pr_gera_efd_registro_K255  @dt_inicial, @dt_final

delete from EFD_REGISTRO_K990

delete from EFD_REGISTRO_1001

delete from EFD_REGISTRO_1010
exec dbo.pr_gera_efd_registro_1010  @dt_inicial, @dt_final

delete from EFD_REGISTRO_1100

delete from EFD_REGISTRO_1105

delete from EFD_REGISTRO_1110

delete from EFD_REGISTRO_1200

delete from EFD_REGISTRO_1210

delete from EFD_REGISTRO_1300

delete from EFD_REGISTRO_1310

delete from EFD_REGISTRO_1320

delete from EFD_REGISTRO_1350

delete from EFD_REGISTRO_1360

delete from EFD_REGISTRO_1370

delete from EFD_REGISTRO_1400

delete from EFD_REGISTRO_1500

delete from EFD_REGISTRO_1510

delete from EFD_REGISTRO_1600

delete from EFD_REGISTRO_1700

delete from EFD_REGISTRO_1710

delete from EFD_REGISTRO_1800

delete from EFD_REGISTRO_1900

delete from EFD_REGISTRO_1910

delete from EFD_REGISTRO_1920

delete from EFD_REGISTRO_1921

delete from EFD_REGISTRO_1922

delete from EFD_REGISTRO_1923

delete from EFD_REGISTRO_1925

delete from EFD_REGISTRO_1926

delete from EFD_REGISTRO_1990

delete from EFD_REGISTRO_9001

delete from EFD_REGISTRO_9900

delete from EFD_REGISTRO_9990

delete from EFD_REGISTRO_9999

exec dbo.pr_atualizacao_bloco_efd_sped_fiscal  @dt_inicial, @dt_final

exec dbo.pr_geracao_efd_sped_fiscal

go
------------------------------------------------------------------------------
--Testando a Stored Procedure
------------------------------------------------------------------------------
--exec pr_geracao_sped_fiscal_egisnet '11/01/2025','11/30/2025'
------------------------------------------------------------------------------