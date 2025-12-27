<template>
  <div>
      <div class="text-h4 text-center text-bold justify-center items-center">
          Registro de Consumo
      </div>
       <div class="row" v-show="menu == 'S' ">
            <q-btn color="orange-8" style="margin:1%; float:left;" size="90%" label="Novo" @click="NovaEntrada()"/>
        </div>
        
    <div>
        <div class="tela-toda">
            <q-input class="meia-tela margin1 col" item-aligned v-model="comanda" @blur="PesquisaComanda()" type="number" label="Comanda">
                <template v-slot:prepend>
                    <q-icon name="bookmark" />
                </template>
            </q-input>
            
            <q-input class="meia-tela margin1" v-show="this.mostra_menu == true"  item-aligned v-model="mesa" type="number" label="Mesa">
                <template v-slot:prepend>
                    <q-icon name="place" />
                </template>
            </q-input>


       
        </div>
        <div class="tela-toda">
            <q-input class="meia-tela margin1" v-show="this.mostra_menu == true"  @blur="PesquisarProduto()" autogrow item-aligned v-model="produto" type="text" label="Produto">
                <template v-slot:prepend>
                    <q-icon name="sell" />
                </template>
            </q-input>

            <q-input v-show="this.mostra_menu == true" class="meia-tela margin1" item-aligned v-model="qt_produto" type="number" @input="onInsereQuantidade()" label="Quantidade">
                <template v-slot:prepend>
                    <q-icon name="bookmark" />
                </template>
            </q-input>
        </div>
          
        <div class="margin1 padding1 text-bold" v-if="vl_unit_produto != '' "> 
            Preço: {{vl_unit_produto}} 
        </div>


        <div v-show="this.mostra_menu == true" class="row">
            <q-checkbox v-model="agendar" label="Agendar"/>
            <q-input v-show="this.agendar == true" mask="##:##" class="col padding1" style="margin-left:5px;" item-aligned v-model="hr_pedido" type="text" label="Horário">
                <template v-slot:prepend>
                    <q-icon name="schedule" />
                </template>
            </q-input>
        </div>
        <div v-show="this.mostra_menu == true" class="col text-right">            

            <q-btn color="positive" style="margin:1%; float:left;" size="90%" label="Gravar" @click="onGravaLocal()">
                <q-tooltip transition-show="scale" transition-hide="scale">
                    Gravar Produto
                </q-tooltip>
            </q-btn>

            <!--<q-btn color="light-blue-5"  style="margin:1%;" size="90%" label="Pedido" @click="MostraPedido()">
                <q-tooltip transition-show="scale" transition-hide="scale">
                    Abre o pedido
                </q-tooltip>
            </q-btn> -->

            <q-btn color="primary"  style="margin:1%; float:left;" size="90%" label="Enviar" @click="EnviarPedido()">
                <q-tooltip transition-show="scale" transition-hide="scale">
                    Enviar Pedido
                </q-tooltip>
            </q-btn>


            <q-btn color="orange-7" style="margin:1%; float:rigth;" size="90%" label="Cardápio" @click="AbreCardapio()">
                <q-tooltip transition-show="scale" transition-hide="scale">
                    Cardápio
                </q-tooltip>
            </q-btn>

            <q-btn color="warning" style="margin:1%; float:rigth;" size="90%" label="Limpar" @click="limpaLabel()">
                <q-tooltip transition-show="scale" transition-hide="scale">
                    Limpar dados
                </q-tooltip>
            </q-btn>
               
        </div>
         <div v-show="this.mostra_pedido == true || this.json_local != [] && this.mostra_menu == true"  >
             <q-separator/>
                
                <div class="row justify-between">
                    <div class="col text-h6 margin1 padding1" v-if="comanda != '' "> 
                        Comanda: {{this.comanda}} 
                    </div>
                    <div class="col text-h6 margin1 padding1" style="float:right" v-if="total_compra != '' "> 
                       {{this.total_compra}}
                    </div>
                </div>
                <div v-show="this.agendar == true && this.hr_pedido != ''" class="col text-h6 margin1 padding1">
                    Horário:{{hr_pedido}}
                </div>
                <div v-show="this.nm_cliente != '' && this.nm_cliente != undefined" class=" text-h6 margin1 padding1"> 
                    Cliente: {{this.nm_cliente}} 
                </div>
    
                <q-card class="margin1">
                    <q-card-section >
                        <DxDataGrid
                            class="margin1"
                            key-expr="cd_controle"
                            :data-source="json_local"
                            :columns="colunas"
                            :show-borders="true"
                            :column-auto-width="true"
                            :column-hiding-enabled="true"
                            :selection="{ mode: 'single' }"
                            :auto-navigate-to-focused-row="true"
                            :hover-state-enabled="true"
                            @row-updated="onCalculaTotal"
                            @saved="onCalculaTotal"
                            @edit-canceled="onCalculaTotal"
                            @row-removed="ExcluirProduto"
 
                        >
                            <DxEditing
                                style="margin:0; padding:0"
                                :allow-updating="true"
                                :allow-deleting="true"
                                mode="batch"
                            />
                            <DxColumn :data-field="colunas[0]"/>
                            <DxColumn :data-field="colunas[1]"/>
                            <DxColumn :data-field="colunas[2]"/>
                            <DxColumn :data-field="colunas[3]"/>

                            
                            <DxPaging :page-size="10"/>
                        </DxDataGrid>
                    </q-card-section> 
                </q-card>
            </div>
<!------------------------------------------------------------------->

            <q-dialog v-model="popup_cardapio" full-height full-width>
            <q-card style="width:120vw;heigth:100vw; margin:2px;"  >
                <q-card-section class="text-h6 margin1 padding1">
                    <div class="margin1 text-h6 text-bold">
                        Cardápio
                        <div style="float:right;">
                            <q-icon name="close" flat round clickable v-close-popup />
                        </div>

                    </div>
                    
                </q-card-section>
                <q-card-section class="margin1 padding1">
                    <q-expansion-item class=" margin1 text-h6 shadow-2 " v-for="(b, index) in dataset_categoria" :key="index" expand-separator :label="b.nm_categoria_produto">
                        <div v-for="(c, chave) in produto_cardapio" :key="chave" style="heigth:auto">
                            <div v-if="c.cd_categoria_produto == b.cd_categoria_produto" style="heigth:auto">
                                <q-list bordered style="heigth:auto">
                                    <q-item class="row items-center text-subtitle2 maring1 " style="heigth:auto" >
                                        <div class="col-2">
                                            <q-avatar class="items-center" color="orange-10" text-color="white" :icon="c.icon"/>
                                        </div>
                                             
                                        <div class="col-6 items-center margin1" style="heigth:auto;float:left"> 
                                            <b>{{c.nm_produto }} <q-badge align="top" rounded color="orange-10" text-color="white" :label="c.qt_saldo_atual_produto" /></b>
                                            <br>
                                            <b>{{c.vl_produto}}</b>
                                            <br>
                                        </div>


                                        <div class="col-4  row items-center" >
                                            <div class="col">
                                                <q-btn size="sm" round color="negative" icon="remove" @click="AlteraQuantidade(produto_cardapio[chave],1 )" />
                                            </div>

                                            <div class="col">
                                                <q-input min="0" class=" col" style="margin:0 10px"   type="number" borderless v-model="c.quantidade_cesta" />
                                            </div>

                                            <div class="col">
                                                <q-btn size="sm" round color="positive" icon="add" @click="AlteraQuantidade(produto_cardapio[chave],2 )" />
                                            </div>
                                        </div>
                                            <!--<q-btn   style="float: right" size="sm"  round color="positive" icon="add"  @click="c.quantidade_cesta ++" />-->
                                            
                                        

                                        <!--<q-item-section>
                                          <q-item-label>{{ c.nm_produto }}</q-item-label>
                                          <q-item-label caption lines="1">{{ c.vl_produto }}</q-item-label>
                                        </q-item-section>

                                        <q-item-section>
                                         <q-item-label caption lines="1">{{ c.ds_produto }}</q-item-label>
                                        </q-item-section>-->
                                    </q-item>
                                </q-list>
                            </div>

                            

                            
                        </div>
                        
                        
                        
                        
                        <!--<div v-for="(b, index2) in produto_cardapio" :key="index2">

                            
                            <div v-if="produto_cardapio.cd_categoria_produto == b.cd_categoria_produto">{{produto_cardapio.nm_produto}}</div>
                        </div>-->
                    </q-expansion-item>
                </q-card-section>
            </q-card>
        </q-dialog>
<!------------------------------------------------------------------->
        <q-dialog v-model="popup_produtos" style="width:120vw;heigth:100vw" full-width>
            <q-card style="width:120vw;heigth:100vw; margin:2px;"  >
                <q-card-section class="text-h6 margin1 padding1">
                    <div>
                        Produtos
                        <div style="float:right;">
                            <q-icon name="close" clickable v-close-popup />
                        </div>

                    </div>
                    
                </q-card-section>
                <q-card-section class="margin1 padding1">
                    <DxDataGrid
                        class="margin1 padding1"
                        key-expr="Codigo"
                        :data-source="dataSource"
                        :columns="dataSource.Descrição"
                        :show-borders="true"
                        :focused-row-enabled="true"
                        :column-auto-width="true"
                        :column-hiding-enabled="false"
                        :remote-operations="false"
                        :word-wrap-enabled="false"
                        :allow-column-reordering="true"
                        :allow-column-resizing="true"
                        :row-alternation-enabled="true"   
                        :repaint-changes-only="true"    
                        :autoNavigateToFocusedRow="true"
                        :focused-row-index="0"      
                        :cacheEnable="false"
                        :selection="{ mode: 'single' }"
                        :auto-navigate-to-focused-row="true"
                        :hover-state-enabled="true"
                        @selection-changed="onSelectionChanged"
                      >
                        <DxPaging :page-size="10"/>
                    </DxDataGrid>
                </q-card-section>
            </q-card>
        </q-dialog>

        </div>
        <div>
            <q-dialog v-model="popup_entrada" maximized>
                <q-card>
                    <q-bar>
                        <q-space />
                        <q-btn dense flat icon="close" v-close-popup>
                            <q-tooltip class="bg-white text-primary">Fechar</q-tooltip>
                        </q-btn>
                    </q-bar>
                    <registroentrada style="width:100%"> </registroentrada>
                </q-card>
            </q-dialog>
        </div>


  </div>
</template>

<script>
import Incluir from '../http/incluir_registro';
import { DxDataGrid, DxPager, DxPaging,DxEditing, DxColumn } from 'devextreme-vue/data-grid';
import notify from 'devextreme/ui/notify';
import registroentrada from './registro-entrada.vue'
import Lookup from '../http/lookup';


export default {
name: 'registro-venda',
    data(){
        return{
            comanda            : '',
            produto            : '',
            cd_mascara_produto: '',
            api                : '593/822',
            popup_produtos     : false,
            mesa               : '',
            dataSource         : {},
            produto_selecionado: {},
            qt_produto         : 1,
            agendar            : false,
            hr_pedido          : '',
            cd_produto         : '',
            vl_produto         : '',
            mostra_pedido      : false,
            json_local         : [],
            colunas            : ['Descrição','Codigo','Preço','Quantidade','cd_controle'],
            total_compra       : '',
            mostra_menu        : true,
            cd_usuario         : 0,
            linha              : [],
            retorno            : 0,
            nm_cliente         : '',
            vl_unit_produto    : '',
            popup_entrada      : false,
            popup_cardapio     : false,
            cd_empresa         : 0,
            menu               : 'N',
            dados_categoria    : [], 
            dataset_categoria  : [],
            dados_mesa         : [], 
            dataset_mesa       : [],
            produto_cardapio   : []
        }
        
    },
    async created(){
        this.cd_empresa = localStorage.cd_empresa;
        this.cd_usuario = localStorage.cd_usuario;

        this.dados_categoria   = await Lookup.montarSelect(this.cd_empresa,261) 
        this.dataset_categoria = JSON.parse(JSON.parse(JSON.stringify(this.dados_categoria.dataset)))

        this.dados_mesa   = await Lookup.montarSelect(this.cd_empresa,4677) 
        this.dataset_mesa = JSON.parse(JSON.parse(JSON.stringify(this.dados_mesa.dataset)))
    

        this.dataset_mesa.sort(function (a,b){
            return a.cd_mesa < b.cd_mesa ? -1 : a.cd_mesa > b.cd_mesa ? 1 : 0;
        });


        this.carregaMenu();
        

    },
    components:{
        DxDataGrid,
        DxPager,
        DxPaging,
        DxEditing,
        DxColumn,
        registroentrada
    },
    watch:{
        popup_cardapio(a,b){
            if(a == false){
                let linha = this.produto_cardapio.filter((value) => {
                    return value.quantidade_cesta > 0;
                });
                var agendamento = 'N'
                for(let n=0; n<linha.length;n++){
                    var l = {
                        "Codigo"      : linha[n].cd_mascara_produto,
                        "Descrição"   : linha[n].nm_produto,
                        "Preço"       : linha[n].vl_produto.replace("R$",""),
                        "Quantidade"  : linha[n].quantidade_cesta,
                        "cd_controle" : linha[n].cd_controle,
                        "ic_agendado" : agendamento,
                        "hr_pedido"   : ''
                    }
                    this.json_local.push(l)
                }
                
                
            }

        }
    },

    methods:{
        AlteraQuantidade(e, seletor){
            if(seletor == 1){
                e.quantidade_cesta = e.quantidade_cesta - 1;
                if(e.quantidade_cesta < 0){
                    e.quantidade_cesta = 0;
                }
            }else if(seletor == 2){
              e.quantidade_cesta = e.quantidade_cesta + 1;  
            }
          
        },
        

        async AbreCardapio(){
            let n = {
                "cd_parametro" : 8
            }
            this.produto_cardapio = await Incluir.incluirRegistro(this.api,n);
            if(this.produto_cardapio[0].Cod == 0){
                notify(this.produto_cardapio[0].Msg);
                return;
            }
            this.popup_cardapio = true;

        },

        async carregaMenu(){
            let o = {
                "cd_parametro" : 7,
                "cd_usuario"   : this.cd_usuario,
                "cd_empresa"   : this.cd_empresa
            }
            let con = await Incluir.incluirRegistro(this.api,o);
            this.menu = con[0].ic_registro_entrada;
        },
        async PesquisarProduto(){

            if(this.produto == '') return;
            
            var pesquisa = {
                "cd_parametro": 1,
                "nm_produto"  : this.produto,
                "cd_mascara_produto" : this.cd_mascara_produto
            }
            this.dataSource = await Incluir.incluirRegistro(this.api,pesquisa);
            if(this.dataSource[0].Cod == 0){
                notify('Nenhum produto encontrado...');
                return;
            }
            else if(this.dataSource.length == 1){
                this.produto            = this.dataSource[0].Descrição;
                this.cd_mascara_produto = this.dataSource[0].Codigo;
                this.cd_produto         = this.dataSource[0].cd_produto;
                this.vl_produto         = this.dataSource[0].Preço;
                this.vl_unit_produto    = this.dataSource[0].Preço
                //this.vl_unit_produto = this.vl_unit_produto.replace(",",".")
                //var num = parseFloat(this.vl_unit_produto)
                //this.vl_unit_produto    = num.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });

                this.qt_produto         = 1;
                return;
            }
            this.popup_produtos = true;
        },
        onSelectionChanged({selectedRowsData}){
            this.produto_selecionado = selectedRowsData[0];

            this.produto            = this.produto_selecionado.Descrição;
            this.cd_mascara_produto = this.produto_selecionado.Codigo;
            this.cd_produto         = this.produto_selecionado.cd_produto;
            this.vl_produto         = this.produto_selecionado.Preço;
            this.vl_unit_produto    = this.produto_selecionado.Preço
            //this.vl_unit_produto = this.vl_unit_produto.replace(",",".")
            //var num = parseFloat(this.vl_unit_produto)
//
            //this.vl_unit_produto    = num.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
            //this.qt_produto         = 1;
            this.popup_produtos     = false;
        },
        limpaLabel(){
            this.produto             = ''
            this.cd_mascara_produto  = ''
            this.produto_selecionado = ''
            this.qt_produto          = 1
        },
        onInsereQuantidade(){
            if(this.qt_produto < 1){
                this.qt_produto = 1
                notify('A quantidade minima deve ser de 1 unidade...');
            }
        },
        onGravaLocal(){  
            if(this.comanda == ''){
                notify('Digite a comanda!');
                return;
            }        
            else if(this.cd_produto == ''){
                notify('Selecione um produto!');
                return;
            }else if(this.agendar == true && this.hr_pedido == ''){
                notify('Digite a hora!');
                return;
            }else if(this.cd_produto == 0){
                notify('Indique o produto')
                this.PesquisarProduto();
                return;
            }
            
            var agendamento = 'N'
            if(this.agendar == true){
                agendamento = 'S'
            }
            this.linha = {
                "Codigo"      : this.cd_mascara_produto,
                "Descrição"   : this.produto,
                "Preço"       : this.vl_produto.replace("R$",""),
                "Quantidade"  : this.qt_produto,
                "cd_controle" : this.cd_produto,
                "ic_agendado" : agendamento,
                "hr_pedido"   : this.hr_pedido
            }
            this.json_local.push(this.linha)
            
            //this.AdicionaGrid();
            this.onCalculaTotal();
            this.limpaLabel();
            this.cd_produto = 0
            this.vl_unit_produto = ''
        },
        
        MostraPedido(){
            this.mostra_pedido = true
        },
        async EnviarPedido(){
            if(this.json_local.length == 0){
                return;
            }
            var capa = {
                "cd_parametro" : 3,
                "cd_usuario"   : this.cd_usuario,
                "cd_comanda"   : this.comanda
            }
            if(this.retorno == 0){ 
                var capa_r = await Incluir.incluirRegistro(this.api,capa);
                notify(capa_r[0].Msg);
                this.retorno = capa_r[0].Cod
            }
            
           
            for(var f = 0; f < this.json_local.length; f++){
                if(this.ic_agendado == 'N'){
                    this.json_local[f].hr_pedido = '';
                }
                let m = null;
                //if(this.mesa.cd_mesa !== undefined){
                    m = this.mesa
                //}
                var g = {
                    "cd_parametro"           : 4,
                    "cd_comanda"             : this.comanda,
                    "cd_registro_venda"      : this.json_local[f].cd_registro_venda,
                    "cd_item_registro_venda" : this.json_local[f].cd_item_registro_venda,
                    "vl_produto"             : this.json_local[f].Preço,
                    "qt_produto"             : this.json_local[f].Quantidade,
                    "cd_produto"             : this.json_local[f].cd_controle,
                    "ic_agendado"            : this.json_local[f].ic_agendado,
                    "hr_pedido"              : this.json_local[f].hr_pedido,
                    "cd_comanda_mesa"        : m

                }

                var insere_itens = await Incluir.incluirRegistro(this.api,g);
                notify(insere_itens[0].Msg)
            }
            this.comanda      = '';
            this.produto      = '';
            this.qt_produto   = 1;
            this.agendar      = '';
            this.agendar      = false;
            this.total_compra = 0;
            this.json_local   = [];
            this.nm_cliente   = '';
            this.mesa         = '';
            
            //this.PesquisaComanda();

        },
        onCalculaTotal(){
            this.total_compra = 0
            for(var a = 0 ;a <this.json_local.length; a++){
                var valor = this.json_local[a].Preço
                if(valor.includes(",")){
                    valor = valor.replace(",",".")
                }
                if(valor.includes("R$")){
                    valor = valor.replace("R$","")
                }
                valor = parseFloat(valor)
                valor = valor * this.json_local[a].Quantidade
                this.total_compra = this.total_compra + valor
            }
            this.total_compra = this.total_compra.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
        },
        async PesquisaComanda(){
            if(this.comanda == ''){
                this.json_local = [];
                this.total_compra = '';
                return;
            }
            notify('Aguarde...')
            this.json_local = []
            var pesquisa = {
                "cd_parametro" : 2,
                "cd_comanda"   : this.comanda
            }
            var pesquisa_c = await Incluir.incluirRegistro(this.api,pesquisa);
            //if(pesquisa_c.length > 0){
            //    this.nm_cliente = pesquisa_c[0].Cliente
            //    this.retorno = pesquisa_c[0].Cod
                if(pesquisa_c[0].Cod == 0){
                    notify(pesquisa_c[0].Msg)
                    this.json_local = [];
                    this.mesa = '';
                    this.mostra_menu = true;
                    return;
                }else{
                    this.json_local = [];
                    
                    this.json_local = pesquisa_c;
                    if(pesquisa_c[0].cd_comanda_mesa > 0){
                        this.mesa = pesquisa_c[0].cd_comanda_mesa;
                    }
                }
            //}
            
            

            notify('Pesquisa concluida')
            this.onCalculaTotal();
            //this.PesquisaCliente();
            notify('Pesquisa concluída')
        },
        async PesquisaCliente(){
            var com = {
                "cd_parametro" : 6,
                "cd_comanda"   : this.comanda
            }
            var pesquisa = await Incluir.incluirRegistro(this.api,com);

            if(pesquisa[0].Cod == 0){
                notify(pesquisa[0].Msg)
                return
            }
        },

        async ExcluirProduto(e){
            var key_exclusao = e.key
            var del = {
                "cd_parametro": 5,
                "cd_comanda"  : this.comanda,
                "cd_produto"  : key_exclusao
            }
            var excluiu = await Incluir.incluirRegistro(this.api,del);
            notify(excluiu[0].Msg)
            this.onCalculaTotal();
        },

        NovaEntrada(){
           
            this.popup_entrada = true
        }
        
    }
    
}
</script>

<style>
.padding1{
    padding: 0.5%;
}
.margin1{
    padding: 0;
    margin: 0.3vw 1vw;
}
.tela-tres{
    width: 30%;
    display: inline-flex;
}
.meia-tela{
  width: 47%;
  display: inline-flex;
}
.tela-toda{
    width: 100%;
}
@media (max-width: 500px){
    .meia-tela{
        width: 100% !important;
    }
    
}
</style>