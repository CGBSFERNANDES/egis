export default{
    DataHoje(){
        var data = new Date();
        var dia = String(data.getDate()).padStart(2, '0');
        var mes = String(data.getMonth() + 1).padStart(2, '0');
        var ano = data.getFullYear();
        let dataAtual = dia + '/' + mes + '/' + ano;
        return dataAtual
    },
    DataEscrita(){ //Kelvin - Traz a data atual escrita
        let dayName = new Array ("Domingo", "Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado")
        let monName = new Array ("Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Agosto", "Outubro", "Novembro", "Dezembro")
        let now = new Date
        let DataEscrita = dayName[now.getDay()] + ', ' + now.getDate() +' de ' + monName[now.getDate()] + ' de ' + now.getFullYear() 
        return DataEscrita
    },
    DataAtual(){ //Kelvin - Traz a data atual
        var data = new Date();
        var dia     = data.getDate();
        var mes     = data.getMonth();
        var ano4    = data.getFullYear();  
        if(dia < 10){
            dia = '0' + dia
        }
        if( mes < 10){
            mes = mes+1
            mes = '0' + mes
        }else {
            mes+1
        }
        let hoje = dia + '/' + mes + '/' + ano4;
        return  hoje
    }
}