<template>
  <div>
    <h3>Importação do XLSX para geração do Json</h3>
    <input type="file" @change="onChange" />
    <xlsx-read :file="file">
      <xlsx-json>
        <template
           #default="{collection}"
          >
            <gravaJson            
            v-if="collection !== ''"
            :json="collection">
           </gravaJson>

          <div>
            {{collection}}
          </div>
        </template>
      </xlsx-json>
    </xlsx-read>


  </div>
</template>

<script>

//import { XlsxRead, XlsxJson } from "../xlsx/vue-xlsx.es";
import { XlsxRead, XlsxJson, XlsxWorkbook } from "@/xlsx/vue-xlsx.es.js";





import gravaJson from '../components/gravaJson';

export default {
  props: {
     fileID : { type: FileList}
  },  
 // emits: ['updateJson'],
  components: {
    XlsxRead,
    XlsxJson,
    XlsxWorkbook,
    gravaJson
  },
  data() {
    return {
      file: null
     
    };
  },
  created() {
    this.file = this.fileID;
  },
  
  methods: {
    onChange(event) {
      this.file = event.target.files ? event.target.files[0] : null;
    },
    onUpdateJson( json ) {
       // eslint-disable-next-line no-console
       console.log(json);
    }
  }
};
</script>