<template>
  <div>
    <DxGantt
      :task-list-width="600"
      :height="700"
      scale-type="weeks"
    >

      <DxTasks :data-source="tasks"/>
      <DxDependencies :data-source="dependencies"/>
      <DxResources :data-source="resources"/>
      <DxResourceAssignments :data-source="resourceAssignments"/>

      <DxToolbar>
        <DxItem name="undo"/>
        <DxItem name="redo"/>
        <DxItem name="separator"/>
        <DxItem name="collapseAll"/>
        <DxItem name="expandAll"/>
        <DxItem name="separator"/>
        <DxItem name="addTask"/>
        <DxItem name="deleteTask"/>
        <DxItem name="separator"/>
        <DxItem name="zoomIn"/>
        <DxItem name="zoomOut"/>
        <DxItem name="separator"/>
        <DxItem
          :options="aboutButtonOptions"
          widget="dxButton"
        />
      </DxToolbar>

      <DxEditing :enabled="true"/>

      <DxColumn
        :width="100"
        data-field="title"
        caption="Cliente"
      />
      <DxColumn
        :width="90"
        data-field="titlez"
        caption="Consultor"
      />
      <DxColumn
        :width="200"
        data-field="title"
        caption="Atividade"
      />
      <DxColumn
        data-field="start"
        caption="Início"
      />
      <DxColumn
        data-field="end"
        caption="Fim"
      />
      <DxColumn
        data-field="end"
        caption="(%)"
      />

    </DxGantt>

    <DxPopup
      :visible="popupVisible"
      title="Informações"
      :height="auto"
      :show-title="true"
      :close-on-outside-click="true"
    >
      <div>
        Cronograma apresenta as atividades e fluxo com as dependências das tarefas de um determinado período.
        <br>
        <br>
        Ajuste a escala de tempo para exibir tarefas em intervalos de tempo menores ou maiores, de horas a anos.
        Segure a tecla CTRL e gire a roda de rolagem do mouse para aumentar ou diminuir o zoom para navegar pelos dados em vários níveis de detalhe.
    </div>
    </DxPopup>
  </div>
</template>

<script>
import {
  DxGantt,
  DxTasks,
  DxDependencies,
  DxResources,
  DxResourceAssignments,
  DxColumn,
  DxEditing,
  DxToolbar,
  DxItem
} from 'devextreme-vue/gantt';
import { DxPopup } from 'devextreme-vue/popup';

import ptMessages from "devextreme/localization/messages/pt.json";
import { locale, loadMessages } from "devextreme/localization";

const tasks = [{
  'id': 1,
  'parentId': 0,
  'title': 'Cronograma',
  'start': new Date('2021-01-05T05:00:00.000Z'),
  'end': new Date('2021-01-14T12:00:00.000Z'),
  'progress': 0
},
{  'id': 2,
  'parentId': 1,
  'title': 'resumo',
  'start': new Date('2021-01-05T05:00:00.000Z'),
  'end': new Date('2021-01-14T12:00:00.000Z'),
  'progress': 0
},
{  'id': 3,
  'parentId': 0,
  'title': 'gsg',
  'start': new Date('2021-01-05T05:00:00.000Z'),
  'end': new Date('2021-01-14T12:00:00.000Z'),
  'progress': 0
},
{  'id': 4,
  'parentId': 3,
  'title': 'g/sca',
  'start': new Date('2021-01-05T05:00:00.000Z'),
  'end': new Date('2021-01-14T12:00:00.000Z'),
  'progress': 0
},

];

const dependencies = [{
  'id': 1,
  'predecessorId': 3,
  'successorId': 4,
  'type': 0
}];

const resources = [{
  'id': 1,
  'text': 'Management'
}];

 const resourceAssignments = [{
  'id': 0,
  'taskId': 3,
  'resourceId': 1
}, {
  'id': 1,
  'taskId': 4,
  'resourceId': 1
}];


export default {
  components: {
    DxGantt,
    DxTasks,
    DxDependencies,
    DxResources,
    DxResourceAssignments,
    DxColumn,
    DxEditing,
    DxToolbar,
    DxItem,
    DxPopup
  },
  data() {
    return {
      tasks: tasks,
      dependencies: dependencies,
      resources: resources,
      resourceAssignments: resourceAssignments,
      popupVisible: false,
      aboutButtonOptions: {
        text: 'Informações',
        icon: 'info',
        stylingMode: 'text',
        onClick: () => {
          this.popupVisible = true;
        }
      }
    };
  },
    created() {
      //locale(navigator.language);
    config({ defaultCurrency: 'BRL' });
    loadMessages(ptMessages);
    locale(navigator.language);
   // locale('pt-BR');
  }

};
</script>
<style>
  #gantt {
    height: 700px;
  }
</style>
