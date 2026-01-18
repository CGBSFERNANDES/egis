alter FUNCTION dbo.CalcularModulo11
(
    @numero NVARCHAR(255)
)
RETURNS INT
AS
BEGIN
    DECLARE @pesos TABLE (peso INT)
    DECLARE @peso INT = 2, @soma INT = 0, @i INT, @resto INT, @digitoVerificador INT
    
    -- Adicionar os pesos (2 até 9)
    WHILE @peso <= 9
    BEGIN
        INSERT INTO @pesos (peso) VALUES (@peso)
        SET @peso = @peso + 1
    END
    
    -- Calcular a soma dos dígitos
    SET @i = LEN(@numero)
    
    WHILE @i > 0
    BEGIN
        SET @peso = (SELECT TOP 1 peso FROM @pesos)
        SET @soma = @soma + CAST(SUBSTRING(@numero, @i, 1) AS INT) * @peso
        
        -- Reajustar o peso (2 a 9 e volta a 2)
        DELETE FROM @pesos WHERE peso = @peso
        INSERT INTO @pesos (peso) VALUES (IIF(@peso < 9, @peso + 1, 2))
        
        SET @i = @i - 1
    END
    
    -- Calcular o resto da soma por 11
    SET @resto = @soma % 11
    SET @digitoVerificador = 11 - @resto
    
    -- Ajustar o dígito conforme a regra do módulo 11
    IF @digitoVerificador = 0 OR @digitoVerificador = 1 OR @digitoVerificador = 10 OR @digitoVerificador = 11
        SET @digitoVerificador = 1
    
    RETURN @digitoVerificador
END
GO

-- Função para calcular o fator de vencimento
alter FUNCTION dbo.CalcularFatorVencimento
(
    @dataVencimento DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @dataBase DATE = '1997-10-07'
    RETURN DATEDIFF(DAY, @dataBase, @dataVencimento)
END
GO

-- Função principal para gerar a linha digitável do boleto Sicoob
--alter FUNCTION dbo.GerarLinhaDigitavelSicoob
alter procedure sp_GerarLinhaDigitavelSicoob

(
    @agencia NVARCHAR(4),
    @conta   NVARCHAR(10),
    @nossoNumero NVARCHAR(7),
    @valor DECIMAL(18, 2),
    @dataVencimento DATE
)
--RETURNS NVARCHAR(255)
AS
BEGIN

    DECLARE @codigoBanco NVARCHAR(3) = '756',
            @moeda NVARCHAR(1) = '9',
			@carteira char(1) = '1',
			@modalidade char(02) = '01',
            @campoLivre NVARCHAR(25),
            @fatorVencimento NVARCHAR(4),
            @valorFormatado NVARCHAR(10),
            @codigoBarrasSemDV NVARCHAR(44),
            @codigoBarrasCompleto NVARCHAR(44),
            @dvCodigoBarras NVARCHAR(1),
            @campo1 NVARCHAR(10) = '',
            @campo2 NVARCHAR(10) = '',
            @campo3 NVARCHAR(10) = '',
            @campo4 NVARCHAR(1)  = '',
            @campo5 NVARCHAR(14),
			@parcela NVARCHAR(3) = '001',
            @linhaDigitavel NVARCHAR(255),
			@ABaseCalculo NVARCHAR(255)
    
    -- Formatar valor em centavos
    SET @valorFormatado = RIGHT('0000000000' + CAST(CAST(@valor * 100 AS INT) AS NVARCHAR(10)), 10)
    
    -- Calcular o fator de vencimento
    SET @fatorVencimento = RIGHT('0000' + CAST(dbo.CalcularFatorVencimento(@dataVencimento) AS NVARCHAR(4)), 4)
    
    -- Montar o campo livre (Agência, Conta, Nosso Número, Tipo Cobrança, Carteira)
    SET @campoLivre = RIGHT('0000' + @agencia, 4) + RIGHT('0000000000' + @conta, 10) + RIGHT('0000000' + @nossoNumero, 7) + '11'
    
    -- Montar o código de barras sem o DV
    --SET @codigoBarrasSemDV = @codigoBanco + @moeda + @fatorVencimento + @valorFormatado + @campoLivre
	                        --+ @campoLivre

	set @ABaseCalculo = RIGHT('0000' + @agencia, 4) + RIGHT('0000000000' + @conta, 10) + RIGHT('0000000' + @nossoNumero, 7)

	--select @ABaseCalculo, LEN(@ABaseCalculo) 

	declare @i  int = 1
	declare @sx int = 0
	declare @soma int = 0
	declare @dig  int = 0

	while @i<=21 
	begin

	  if @i in (1,5,9,13,17,21) 
	  begin
	    set @sx = 3
      end
       if @i in (2,5,10,14,18)
	       begin
	          set @sx =1
           end
       if @i in (3,6,11,15,19)
	       begin
	         set @sx = 9
		   end
	   if @i in (4,7,12,16,20)
	       begin
	         set @sx = 7
           end

      set @soma = @soma + ( @sx * CAST(SUBSTRING(@ABaseCalculo,@i,1) as int))
	  set @i = @i + 1

     end 

	--select @soma

	if @soma % 11 <=1 
	   set @dig = 0
    else
	   set @dig = 11 - ( @soma % 11 )

    --select @dig

	    SET @codigoBarrasSemDV = @codigoBanco     +
		                         @moeda           + 
								 @fatorVencimento + 
								 @valorFormatado  +
	                             @carteira        +
							     @agencia         +
							     @modalidade      + 
							     RIGHT('0000000000' + @conta, 10)      +
							     RIGHT('0000000'    + @nossoNumero, 7) + CAST(@dig as char(1)) +
							     RIGHT('000'        + @parcela,3 )


     --select @codigoBarrasSemDV, LEN(@codigoBarrasSemDV)							     

	--end

	--SET @dvCodigoBarras = CAST(dbo.CalcularModulo11(@ABaseCalculo) AS NVARCHAR(1))
	--select @dvCodigoBarras 

    -- Calcular o DV do código de barras
    SET @dvCodigoBarras = CAST(dbo.CalcularModulo11(@codigoBarrasSemDV) AS NVARCHAR(1))

    if @dvCodigoBarras = '0' 
	begin
	   set @dvCodigoBarras = 1 
    end

	--select @dvCodigoBarras

    -- Montar o código de barras completo
    SET @codigoBarrasCompleto = @codigoBanco + @moeda + @dvCodigoBarras + SUBSTRING(@codigoBarrasSemDV,5,len(@codigoBarrasSemDV))

	select @codigoBarrasCompleto, LEN(@codigoBarrasCompleto)
	--         1         2         3         4   
	--12345678901234567890123456789012345678901234
	--75692986900000309981321401000343484200014850

	--32143434842 = 1
	--3214343484210001485 = 
	--+ @fatorVencimento + @valorFormatado + @campoLivre
    
    -- Montar os campos da linha digitável

    SET @campo1 = SUBSTRING(@codigoBarrasCompleto, 1, 4)   + SUBSTRING(@codigoBarrasCompleto, 20, 5) + CAST(dbo.CalcularModulo11(SUBSTRING(@codigoBarrasCompleto, 1, 9)) AS NVARCHAR(1))
    SET @campo2 = SUBSTRING(@codigoBarrasCompleto, 25, 10) + CAST(dbo.CalcularModulo11(SUBSTRING(@codigoBarrasCompleto, 25, 10)) AS NVARCHAR(1))
    SET @campo3 = SUBSTRING(@codigoBarrasCompleto, 35, 10) + CAST(dbo.CalcularModulo11(SUBSTRING(@codigoBarrasCompleto, 35, 10)) AS NVARCHAR(1))
    SET @campo4 = @dvCodigoBarras
    SET @campo5 = @fatorVencimento + @valorFormatado



    --SET @campo1 = SUBSTRING(@codigoBarrasCompleto, 1, 4)   + SUBSTRING(@codigoBarrasCompleto, 20, 5) + CAST(dbo.CalcularModulo11(SUBSTRING(@codigoBarrasCompleto, 1, 9)) AS NVARCHAR(1))
    --SET @campo2 = SUBSTRING(@codigoBarrasCompleto, 25, 10) + CAST(dbo.CalcularModulo11(SUBSTRING(@codigoBarrasCompleto, 25, 10)) AS NVARCHAR(1))
    --SET @campo3 = SUBSTRING(@codigoBarrasCompleto, 35, 10) + CAST(dbo.CalcularModulo11(SUBSTRING(@codigoBarrasCompleto, 35, 10)) AS NVARCHAR(1))
    --SET @campo4 = @dvCodigoBarras
    --SET @campo5 = @fatorVencimento + @valorFormatado
    
	select @campo1, @campo2, @campo3, @campo4, @campo5

    -- Montar a linha digitável
    SET @linhaDigitavel = LEFT(@campo1, 5) + '.' + SUBSTRING(@campo1, 6, 5) + ' ' +
                          LEFT(@campo2, 5) + '.' + SUBSTRING(@campo2, 6, 6) + ' ' +
                          LEFT(@campo3, 5) + '.' + SUBSTRING(@campo3, 6, 6) + ' ' +
                          @campo4 + ' ' + 
						  @campo5
    
    --RETURN @linhaDigitavel
	select @linhaDigitavel

END
GO

-- Exemplo de uso para gerar a linha digitável de um boleto Sicoob
--DECLARE @linhaDigitavel NVARCHAR(255)
--SET @linhaDigitavel = 
exec sp_GerarLinhaDigitavelSicoob '3214', '3434842', '0001485', 309.98, '10-14-2024'
--SELECT @linhaDigitavel AS LinhaDigitavel

select '75691.32140 01343.484208 00148.500010 1 98690000030998' as correto

--------------------------------------------------