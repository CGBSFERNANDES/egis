let usuario = '';
 
export default {
  registro( sUser ) {
    if (sUser !='') {
       usuario = sUser; 
    } else {
        usuario = 'GBS';
    }
    return usuario;
  }
};
