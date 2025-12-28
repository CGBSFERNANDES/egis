CREATE PROCEDURE pr_gera_atualizacao_moeda_cotacao  
    @moeda VARCHAR(10),  
    @data_cotacao DATE,  
    @cotacao DECIMAL(18,6)  
AS  
BEGIN  
    SET NOCOUNT ON;  
  
    INSERT INTO Moeda_Cotacao (moeda, data_cotacao, cotacao)  
    VALUES (@moeda, @data_cotacao, @cotacao);  
END;  