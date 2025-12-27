const express = require('express');
const path = require('path');
const session = require('express-session');
const sql = require('mssql');
const { getPool } = require('./db');
const cors = require("cors");
const { exec } = require('child_process');

//require('dotenv').config();


//const compression = require('compression');

// Importar rotas dos módulos
// === Importar as rotas do módulo ===
const caixaLogisticaRoutes = require('../src/modules/caixaLogistica/caixaLogistica.route');
const veloeRoutes = require('../src/modules/veloe/veloe.routes');
const serasaRoutes = require('../src/modules/serasa/serasa.routes');
const monitorRoutes = require('../src/modules/monitor/monitor.routes');
const chatRoutes = require('../src/modules/chat/chat.routes');
const logisticaRoutes = require('../src/modules/logistica/logistica.routes');
const financeiroRoutes = require('../src/modules/financeiro/financeiro.routes');
const nfeRoutes = require('../src/modules/NFe/validacaoNFe.route');
const cnpjDocsRoutes = require('../src/modules/cnpj/cnpjDocs.route');
const validacaoRoutes = require('../src/modules/comercial/validacaoEntrada.routes');
const relatorioRoutes = require('../src/modules/relatorio/relatorio.routes');
const dfeRoutes = require('../src/modules/NFe/dfe.route');

//////////////////////////////////////////////////////////////////////////////////

const app = express();

const PORT = 3000;

// Middlewares

//app.use(cors());
app.use(cors({
  origin: '*', // ou '*' se quiser liberar geral
  // methods: ['GET', 'POST', 'OPTIONS'],
  // allowedHeaders: ['Content-Type'],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-servico-fila', 'x-banco'],
  credentials: false
}));


//app.use(express.json()); // ← ESSENCIAL para ler JSON no req.body
//app.use(express.urlencoded({ extended: true }));
//app.use(compression()); // usa GZIP automático

app.use(express.json({ limit: '80mb' }));
app.use(express.urlencoded({ extended: true, limit: '80mb' }));


// 🔓 Expor uploads publicamente
// Libera acesso direto aos uploads
app.use('/img/uploads', express.static(path.join(__dirname, 'public/uploads')));
//

// Middleware de log (coloca aqui logo depois da criação do app)
app.use((req, res, next) => {
  console.log("🔍 Rota acessada: ", req.method, req.url);
  next();
});
//

//dados da Empresa
//let cd_empresa = 0;
let nm_banco = '';
//


//app.set('trust proxy', true); // usa X-Forwarded-* do proxy
//PUBLIC_ORIGIN=https://egiserp.com.br
//const PUBLIC_ORIGIN = process.env.PUBLIC_ORIGIN || `http://localhost:${PORT}`;
// helper para obter a origem pública correta
/*
function getPublicOrigin(req) {
  if (process.env.PUBLIC_ORIGIN) return process.env.PUBLIC_ORIGIN;
  const xfHost  = (req.headers['x-forwarded-host'] || '').split(',')[0].trim();
  const xfProto = (req.headers['x-forwarded-proto'] || '').split(',')[0].trim();
  if (xfHost) return `${xfProto || 'https'}://${xfHost}`;
  return `${req.protocol}://${req.get('host')}`;
}
*/
//app.use(express.json({ limit: "5mb" })); // já no topo do seu server.js


//app.use(express.static(path.join(__dirname, 'public')));

//18.05.2025
//app.get('/', (req, res) => {
//  res.redirect('/login'); // ou res.send('Página principal'), se quiser algo diferente
//});

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'public', 'login.html'));
});

/////



app.use(express.static('public'));

app.use(session({
  secret: 'egis_secret_key',
  resave: false,
  saveUninitialized: false, // bom prática: false, para não salvar sessões vazias
  cookie: {
    //secure: false,
    //sameSite: "none",
    maxAge: 60 * 60 * 1000000 // 1 hora = 3600000 ms
  }
}));


const { autenticarViaBase64 } = require("./services/auth.service");
const atob = require("atob");

// helper no topo do index.js (depois dos requires)
function resolveBanco(req, { fallback = 'EGISCNPJ' } = {}) {
  const origemServico = req.headers['x-servico-fila'];
  // Prioridades comuns:
  const headerBanco = req.headers['x-banco'];
  const queryBanco  = req.query?.banco;
  const sessBanco   = req.session?.nm_banco || req.session?.nm_banco_empresa;

  if (origemServico === 'egiscnpj' || origemServico === 'validacaoproposta') {
    // serviços internos: preferem o que vem no payload 0 ou header/query
    const payload0Banco = Array.isArray(req.body) ? req.body?.[0]?.nm_banco_empresa : req.body?.nm_banco_empresa;
    return payload0Banco || headerBanco || queryBanco || fallback;
  }

  return headerBanco || queryBanco || sessBanco || fallback;
}
//


// ➕ LIBERAÇÃO PÚBLICA (sem login) para as rotas de correção e informativo NFe
const PUBLIC_NFE_PATHS = [
  /^\/api\/nfe\/nfce\/correcao\/[^/?#]+(?:\?.*)?$/i,
  /^\/api\/nfe\/nfce\/correcao\/[^/?#]+\/dados(?:\?.*)?$/i,
  /^\/api\/nfe\/nfce\/correcao\/\d+(?:\?.*)?$/i,
  /^\/api\/nfe\/nfce\/correcao\/\d+\/validar(?:\?.*)?$/i,
  /^\/api\/nfe\/nfce\/danfe\/[^/?#]+(?:\?.*)?$/i,
  /^\/api\/nfe\/danfe\/[^/?#]+(?:\?.*)?$/i,
  /^\/api\/nfe\/processar\/[^/?#]+(?:\?.*)?$/i,    
   // 🔹 storage: logs/notas (listagem html)
  /^\/api\/nfe\/storage\/(logs|notas)$/i,
  // 🔹 storage: zip de logs/notas
  /^\/api\/nfe\/storage\/(logs|notas)\/zip$/i,
  // 🔹 storage: limpar todos (POST)
  /^\/api\/nfe\/storage\/(logs|notas)\/clear$/i,
  // 🔹 storage: download/delete de 1 arquivo
  /^\/api\/nfe\/storage\/file$/i,
  /^\/api\/nfe\/storage\/notas\/rename-xml$/i,
   
];
//


// Middleware para proteger rotas

async function protegerRota(req, res, next) {

  console.log("🔒 Middleware protegerRota → URL:", req.url);
  //console.log("🔒 Headers:", req.headers);

  // ✅ Whitelist: correção/visualização de NFe sem exigir sessão
  if (PUBLIC_NFE_PATHS.some(rx => rx.test(req.url))) {
    return next();
  }


  if (
    req.session?.usuario ||
    req.headers["x-servico-fila"] === "egiscnpj" || // ← do serviço
    req.headers["authorization"] === "Bearer superchave123" || // ← opcional
    req.url.includes("pr_validacao_cnpj_api_cnpj_ja") || // ← exceção direta
    req.url.includes("/api/relatorio/gerar-relatorio-html") || // ← ADICIONE ISSO TEMPORARIAMENTE
    req.url.includes("/relatorio_processo.html") ||
    req.url.includes("/dashboard_processo.html") ||
    // req.url.includes("/agenda_processo.html") ||
    req.url.includes("/agenda_processo.html") || // ✅ Correto agora
    req.url.includes("/api/relatorio/gerar-agenda-html") ||
    req.url.includes("/api/relatorio/payload-tabela") ||
    req.url.includes("/api/relatorio/feriados") ||
    req.url.includes("/api/relatorio/entregas") 

  ) {
    return next();
  }


  //
  // 🧩 NOVA VERIFICAÇÃO → autenticação por dados_b64

  try {
    if (req.query?.dados_b64) {
      const json = JSON.parse(atob(req.query.dados_b64));
      const { banco, login, senha } = json;

      if (banco && login && senha) {
        const usuario = await autenticarViaBase64({ banco, login, senha });

        if (usuario) {
          req.session = req.session || {};
          req.session.usuario = {
            cd_usuario: usuario.cd_usuario,
            nm_usuario: usuario.nm_usuario,
            cd_empresa: json.cd_empresa || null,
          };
          return next();
        }
      }

      console.warn("🔒 Autenticação via base64 falhou.");
    }
  } catch (err) {
    console.error("❌ Erro ao autenticar com dados_b64:", err);
  }

  //




  //
  return res.redirect("/login");
  //

}


/////
//07.06.2025
////

// Rota da tela de login

//18.05.2025
app.get('/login', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'public', 'login.html'));
});

//app.get('/login', (req, res) => {
//  if (req.session && req.session.usuario && req.session.usuario !== '') {
//    // Se já autenticado, redireciona para a tela principal
//    return res.redirect('/');
//  }
//
// res.sendFile(path.join(__dirname, '..', 'public', 'login.html'));
//
//});



// Autenticação

app.post('/login', async (req, res) => {
  const { username, password } = req.body;

  try {
    const pool = await getPool('egisAdmin');

    const result = await pool.request()
      .input('cd_parametro', sql.Int, 0)
      .input('nm_fantasia_usuario', sql.VarChar, username)
      .input('cd_senha_usuario', sql.VarChar, password)
      .input('nm_email_usuario', sql.VarChar, '')
      .input('ic_tipo_senha', sql.Char, 'P')
      .input('cd_contato', sql.Int, 0)
      .execute('pr_egis_validacao_acesso_usuario');

    //console.log(result.recordset);

    const user = result.recordset?.[0];

    //console.log('user', user);

    await pool.close();

    if (!user || user.cd_senha_usuario !== password.toUpperCase()) {
      return res.send('<h4>Usuário ou senha inválidos. <a href="/login">Tentar novamente</a></h4>');
    }

    // Salva na sessão dados do usuário

    req.session.perfil = user.perfil;
    req.session.cd_empresa = user.cd_empresa;
    req.session.nm_banco_empresa = user.nm_banco_empresa?.trim() || '';
    req.session.url_usuario = user.url_usuario;
    req.session.usuario = user.nm_fantasia_usuario;
    req.session.nome = user.nm_usuario;
    req.session.nm_fantasia_empresa = user.nm_fantasia_empresa;
    req.session.nm_empresa = user.nm_empresa;
    req.session.nm_logo_empresa = user.nm_caminho_logo_empresa;
    req.session.cd_modulo = user.cd_modulo;
    req.session.nm_modulo = user.nm_modulo;
    req.session.cd_usuario = user.cd_usuario;
    req.session.nm_email_usuario = user.nm_email_usuario;
    req.session.cd_celular_usuario = user.cd_celular_usuario;
    req.session.dt_nascimento_suario = user.dt_nascimento_suario;
    req.session.nm_logo_empresa = 'https://egisnet.com.br/img/' + user.nm_caminho_logo_empresa;
    req.session.vb_foto = user.vb_base64;
    req.session.cd_modulo_start = user.cd_modulo_start;
    req.session.cd_modulo = user.cd_modulo_start;
    req.session.nm_modulo_start = 'EGIS - Soluções Integradas';
    req.session.nm_banco_empresa = user.nm_banco_empresa.trim();
    req.session.cd_vendedor = user.cd_vendedor;
    //cd_empresa = user.cd_empresa;
    nm_banco = user.nm_banco_empresa.trim();;
    global.nm_banco = user.nm_banco_empresa.trim();

    //console.log(req.session.cd_empresa);

    //res.redirect('/');

    //console.log("Sessão real:", {
    //  banco: req.session.nm_banco_empresa,
    //  empresa: req.session.cd_empresa
    //});

    req.session.save(err => {
      if (err) {
        console.error("Erro ao salvar sessão no login:", err);
        return res.status(500).send("Erro na sessão");
      }

      // res.redirect('/');
      //res.redirect('/modulos'); // ou outra rota interna da sua aplicação logada

      res.sendFile(path.join(__dirname, '..', 'public', 'index.html'));

    });

  } catch (err) {
    console.error('Erro no login:', err);
    res.status(500).send('Erro no login');
  }
});

//
// index.js (ou sua rota de login especial)
app.post("/login-express", async (req, res) => {
  const { cd_usuario, cd_empresa, nm_banco } = req.body;

  if (!cd_usuario || !cd_empresa || !nm_banco) {
    return res.status(400).json({ error: "Parâmetros obrigatórios ausentes." });
  }

  // Simule carregamento de dados do usuário se necessário
  req.session.cd_usuario = cd_usuario;
  req.session.cd_empresa = cd_empresa;
  req.session.nm_banco = nm_banco;
  req.session.nm_usuario = "AutoLogin";
  req.session.usuario = "AutoLogin"; // ← ESSENCIAL

  //
  return res.json({ ok: true });
  //

});


//

app.get('/modulos', protegerRota, async (req, res) => {
  const pool = await getPool('egisAdmin');

  try {
    const result = await pool.request()
      .input('cd_usuario', sql.Int, req.session.cd_usuario)
      .execute('pr_egis_acesso_modulo');

    res.json(result.recordset);
  } catch (err) {
    console.error('Erro ao buscar módulos:', err);
    res.status(500).send('Erro ao buscar módulos');
  }
});


// Logout

app.get('/logout', (req, res) => {
  req.session.destroy(() => {
    res.clearCookie('connect.sid');
    res.redirect('/login');
  });
});


app.get('/dados-usuario', protegerRota, (req, res) => {

  //console.log(req.body);

  if (!req.session.usuario) return res.status(401).json({ erro: 'Não autenticado' });

  res.json({
    cd_empresa: req.session.cd_empresa,
    cd_usuario: req.session.cd_usuario,
    usuario: req.session.usuario,
    nome: req.session.nome,
    nm_fantasia_empresa: req.session.nm_fantasia_empresa,
    nm_empresa: req.session.nm_empresa,
    cd_modulo_start: req.session.cd_modulo_start,
    cd_modulo: req.session.cd_modulo_start,
    nm_modulo: req.session.nm_modulo,
    logo: req.session.nm_logo_empresa,
    nm_banco: req.session.nm_banco_empresa,
    avatar: req.session.url_usuario,
    cd_vendedor: req.session.cd_vendedor
  });

});

app.get('/registrar', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'views', 'registrar.html'));
});

const bcrypt = require('bcrypt');

app.post('/registrar', async (req, res) => {
  const { nome, usuario, senha, perfil } = req.body;

  try {
    const hash = await bcrypt.hash(senha, 10);

    const pool = await getPool('egisDB');
    await pool.request()
      .input('nome', sql.NVarChar, nome)
      .input('usuario', sql.NVarChar, usuario)
      .input('senha', sql.NVarChar, hash)  // aqui salva o hash
      .input('perfil', sql.NVarChar, perfil)
      .query('INSERT INTO usuarios (nome, usuario, senha, perfil) VALUES (@nome, @usuario, @senha, @perfil)');

    await pool.close();

    res.redirect('/login');

  } catch (err) {
    console.error(err);
    res.status(500).send('Erro ao registrar usuário');
  }
});


app.get('/api/menu-lateral', protegerRota, async (req, res) => {
  try {
    //const cd_modulo = 282;

    const cd_modulo = parseInt(req.query.modulo) || req.session.cd_modulo_start;
    const cd_empresa = req.session.cd_empresa || 0;
    const cd_usuario = req.session.cd_usuario || 0;

    const pool = await getPool('egisAdmin');


    const result = await pool.request()
      .input('cd_modulo', sql.Int, cd_modulo)
      .input('cd_empresa', sql.Int, cd_empresa)
      .input('cd_usuario', sql.Int, cd_usuario)
      .execute('pr_egis_modulo_sidenav');

    await pool.close();

    //console.log(result.recordset[0]);

    const jsonData = JSON.parse(result.recordset[0].data);

    //console.log(jsonData);

    res.json(jsonData); // ou .output caso use output params

  } catch (err) {
    console.error('Erro ao buscar menu lateral:', err);
    res.status(500).json({ erro: 'Erro ao buscar menu lateral' });
  }
});


app.get('/session-info', (req, res) => {
  res.json({
    usuario: req.session?.usuario || null,
    nome: req.session?.nome || null,
    perfil: req.session?.perfil || null
  });
});

app.get('/recuperar', (req, res) => {
  res.sendFile(path.join(__dirname, '..', 'views', 'recuperar.html'));

});

const crypto = require('crypto');

app.post('/recuperar-senha', async (req, res) => {
  const { usuario } = req.body;
  const token = crypto.randomBytes(32).toString('hex');
  const expiracao = new Date(Date.now() + 3600000); // 1h de validade

  try {
    const pool = await getPool('egisDB');
    const result = await pool.request()
      .input('usuario', sql.VarChar, usuario)
      .query('SELECT usuario FROM usuarios WHERE usuario = @usuario or nm_email_usuario = @usuario');

    //console.log(result);

    if (result.recordset.length === 0) {
      await pool.close();
      return res.send(`<h4 style="text-align:center;">Usuário não encontrado. <a href="/recuperar">Tentar novamente</a></h4>`);
    }

    //console.log(token);

    // Salva token
    await pool.request()
      .input('usuario', sql.VarChar, usuario)
      .input('token', sql.VarChar, token)
      .input('data_expiracao', sql.DateTime, expiracao)
      .query(`
          INSERT INTO tokens_recuperacao (usuario, token, data_expiracao)
          VALUES (@usuario, @token, @data_expiracao)
        `);

    await enviarEmailRecuperacao(usuario, token);
    await pool.close();

    res.send(`<h4 style="text-align:center;">Link de recuperação enviado para ${usuario}.</h4><div style="text-align:center;"><a href="/login">Voltar ao login</a></div>`);
  } catch (err) {
    console.error("Erro ao processar recuperação:", err);
    res.status(500).send("Erro interno ao tentar recuperar senha.");
  }
});

app.get('/redefinir-senha', async (req, res) => {
  const { token } = req.query;
  if (!token) return res.send("Token inválido.");

  try {
    const pool = await getPool('egisDB');
    const result = await pool.request()
      .input('token', sql.VarChar, token)
      .query('SELECT * FROM tokens_recuperacao WHERE token = @token AND data_expiracao >= GETDATE()');

    await pool.close();

    if (result.recordset.length === 0) {
      return res.send("Token expirado ou inválido.");
    }

    // Renderiza a tela de redefinição      
    res.sendFile(path.join(__dirname, '..', 'views', 'redefinir.html'));

  } catch (err) {
    res.status(500).send("Erro ao validar token.");
  }
});

app.post('/redefinir-senha', async (req, res) => {
  const { token, senha } = req.body;
  if (!token || !senha) return res.send("Dados incompletos.");

  try {
    const pool = await getPool('egisDB');
    const result = await pool.request()
      .input('token', sql.VarChar, token)
      .query('SELECT * FROM tokens_recuperacao WHERE token = @token AND data_expiracao > GETDATE()');

    if (result.recordset.length === 0) {
      await pool.close();
      return res.send("Token expirado ou inválido.");
    }

    const usuario = result.recordset[0].usuario;
    const hash = await bcrypt.hash(senha, 10);

    await pool.request()
      .input('novaSenha', sql.VarChar, hash)
      .input('usuario', sql.VarChar, usuario)
      .query('UPDATE usuarios SET senha = @novaSenha WHERE usuario = @usuario');

    await pool.request()
      .input('token', sql.VarChar, token)
      .query('DELETE FROM tokens_recuperacao WHERE token = @token');

    await pool.close();
    res.send(`<h4>Senha atualizada com sucesso. <a href="/login">Ir para o login</a></h4>`);
    //res.sendFile(path.join(__dirname, 'views/sucesso.html'));
    res.sendFile(path.join(__dirname, '..', 'views', 'sucesso.html'));
  } catch (err) {
    console.error(err);
    res.status(500).send("Erro ao redefinir senha.");
  }
});


const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host: 'smtp.email-ssl.com.br',
  port: 465,
  secure: true, // SSL
  auth: {
    user: 'carlos@gbsnet.com.br', // seu email completo
    pass: '#Gbs@2025ccf#',              // sua senha
  },
});



async function enviarEmailRecuperacao(destino, token) {
  const link = `http://localhost:4000/redefinir-senha?token=${token}`;
  const mailOptions = {
    from: '"Egis - Recuperação de Senha" <SEU_EMAIL@gmail.com>',
    to: destino,
    subject: 'Recuperação de Senha - EGIS',
    html: `<p>Olá,</p>
             <p>Recebemos uma solicitação para redefinir sua senha. Clique no link abaixo para continuar:</p>
             <p><a href="${link}">${link}</a></p>
             <p>Este link expira em 1 hora.</p>
             <p>Se você não solicitou, ignore este e-mail.</p>`
  };

  await transporter.sendMail(mailOptions);
}


app.post('/api/menu-filtro', protegerRota, async (req, res) => {
  const pool = await getPool('egisAdmin');

  //console.log(req.body);

  try {
    const filtrosInput = [{
      cd_menu: req.body.cd_menu,
      cd_usuario: req.body.cd_usuario
    }];

    const result = await pool.request()
      .input('json', sql.NVarChar, JSON.stringify(filtrosInput))
      .execute('pr_gera_menu_filtro');

    res.json(result.recordset); // espera-se: array com os campos

    console.log(result.recordset);

  } catch (err) {
    console.error('Erro no filtro:', err);
    res.status(500).send('Erro ao carregar filtros');
  }
});

app.post('/api/menu-relatorio', protegerRota, async (req, res) => {
  //const pool = await getPool('egisAdmin');
  const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo

  //const pool = await getPool(req.session.nm_banco);

  //console.log(req.body);

  try {
    const json = JSON.stringify(req.body); // já é array!


    console.log("SQL que será executado:");
    console.log(json);

    const result = await pool.request()
      .input('json', sql.NVarChar, json)
      .execute('pr_egis_relatorio_padrao');

    res.json(result.recordset);

    console.log(result.recordset);

  } catch (err) {
    console.error("Erro na consulta de dados:", err);
    res.status(500).send("Erro ao consultar dados.");
  }
});

app.post('/api/menu-pesquisa', protegerRota, async (req, res) => {
  //const pool = await getPool('egisAdmin');
  let banco;

  banco =
        req.headers["x-banco"] ||             // dashboards externos
        req.query.banco ||                    // agenda externa
        req.session?.nm_banco ||              // dashboards internos (login)
        `${nm_banco}` ||
        null;

  console.log("Banco selecionado na pesquisa:", banco);
        
  //const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo
  
  const pool = await getPool(`${banco}`); // usa o pool do banco certo
  //

  //const pool = await getPool(req.session.nm_banco);

  //console.log(req.body);

  try {
    const json = JSON.stringify(req.body); // já é array!


    console.log("SQL que será executado:");
    console.log(json);

    const result = await pool.request()
      .input('json', sql.NVarChar, json)
      .execute('pr_egis_pesquisa_dados');

    res.json(result.recordset);

    console.log(result.recordset);

  } catch (err) {
    console.error("Erro na consulta de dados:", err);
    res.status(500).send("Erro ao consultar dados.");
  }
});

app.get('/api/usuario-empresas', protegerRota, async (req, res) => {
  const cd_usuario = req.session.cd_usuario || 0;
  const pool = await getPool('egisAdmin'); // ou banco certo

  try {
    const result = await pool.request()
      .input('cd_empresa', sql.Int, 0)
      .input('cd_parametro', sql.Int, 0)
      .input('cd_usuario', sql.Int, cd_usuario)
      .execute('pr_consulta_usuario_empresa');

    // console.log(result.recordset);

    res.json(result.recordset);

    //cd_empresa                       = result.cd_empresa;
    //nm_banco                         = result.nm_banco_empresa.trim();;

    //console.log(cd_empresa);

  } catch (err) {
    console.error('Erro ao buscar empresas:', err);
    res.status(500).send('Erro ao buscar empresas');
  }

});


app.post('/api/selecionar-empresa', protegerRota, async (req, res) => {

  console.log(req.body);

  const { cd_empresa, nm_banco_empresa, nm_empresa, nm_fantasia_empresa, imageUrl } = req.body;

  if (!cd_empresa || !nm_banco_empresa) {
    return res.status(400).json({ error: "Dados incompletos" });
  }

  // console.log(nm_fantasia_empresa);

  // Atualiza a sessão diretamente
  req.session.cd_empresa = cd_empresa;
  req.session.nm_empresa = nm_empresa;
  req.session.nm_banco = nm_banco_empresa;
  req.session.nm_fantasia_empresa = nm_fantasia_empresa;
  req.session.nm_caminho_logo_empresa = imageUrl;

  //req.session.nm_empresa = nm_empresa;

  // cd_empresa                       = cd_empresa;
  nm_banco = nm_banco_empresa.trim();
  global.nm_banco = nm_banco_empresa.trim();

  req.session.save(err => {
    if (err) {
      console.error("Erro ao salvar session:", err);
      return res.status(500).send("Erro ao salvar sessão");
    }

    res.json({ sucesso: true, mensagem: "Empresa selecionada. Limpar cache." });

    //res.json({ sucesso: true });

    //res.json({ message: "Empresa selecionada com sucesso" });
  });

});

app.get('/procedure/menu/:cd_menu', async (req, res) => {
  const { cd_menu } = req.params;
  const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo
  try {
    //await sql.connect(dbConfig);
    const result = await pool.request()
      .query(`
        SELECT TOP 1 nome_procedure
        FROM meta_procedure_colunas
        WHERE cd_menu_id = ${cd_menu}
      `);

    if (result.recordset.length === 0) {
      return res.status(404).json({ error: 'Procedure não encontrada para este menu.' });
    }

    res.json({ procedure: result.recordset[0].nome_procedure });
  } catch (err) {
    console.error("Erro ao buscar procedure:", err);
    res.status(500).json({ error: 'Erro ao buscar procedure' });
  }
});

app.get('/parametros/menu/:cd_menu', async (req, res) => {
  const { cd_menu } = req.params;
  const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo
  //console.log(nm_banco);

  try {
    //await sql.connect(dbConfig);

    const result = await pool.request()
      .query(`
      SELECT distinct m.cd_menu_id, mp.nome_procedure, nome_parametro, tipo_parametro, valor_padrao, obrigatorio, editavel, ordem_parametro, titulo_parametro
      FROM meta_procedure_parametros mp
           inner join meta_procedure_colunas m on m.nome_procedure = mp.nome_procedure
      WHERE m.cd_menu_id = ${cd_menu}
      order by
        mp.ordem_parametro
    `);
    res.json(result.recordset);
  } catch (err) {
    console.error("Erro ao buscar parâmetros:", err);
    res.status(500).json({ error: 'Erro ao buscar parâmetros' });
  }
});

app.post('/exec/menu/:cd_menu', async (req, res) => {
  const { cd_menu } = req.params;
  const { parametros } = req.body;
  const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo

  try {
    //await sql.connect(dbConfig);

    // 1. Buscar nome da procedure pelo menu

    const procRes = await pool.request()

      .query(`
      SELECT TOP 1 nome_procedure
      FROM meta_procedure_colunas
      WHERE cd_menu_id = ${cd_menu}
    `);

    if (procRes.recordset.length === 0) {
      return res.status(404).json({ error: 'Procedure não encontrada.' });
    }

    const procedure = procRes.recordset[0].nome_procedure;

    // 2. Executar procedure com os parâmetros enviados

    const request = pool.request();

    for (const [key, value] of Object.entries(parametros)) {
      request.input(key, value);
    }

    const result = await request.execute(procedure);


    res.json(result.recordset);


  } catch (err) {
    console.error("Erro ao executar procedure:", err);
    res.status(500).json({ error: 'Erro ao executar procedure' });
  }
});

app.get('/colunas/menu/:cd_menu', async (req, res) => {
  const { cd_menu } = req.params;
  const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo

  try {
    //await sql.connect(dbConfig);

    const result = await pool.request()
      .query(`
      SELECT *
      FROM meta_procedure_colunas
      WHERE cd_menu_id = ${cd_menu}
    `);
    res.json(result.recordset);
  } catch (err) {
    console.error("Erro ao buscar colunas:", err);
    res.status(500).json({ error: 'Erro ao buscar colunas' });
  }
});

app.post('/exec/menu/:cd_menu', async (req, res) => {
  const { cd_menu } = req.params;
  const { parametros } = req.body;
  const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo

  try {
    //await sql.connect(dbConfig);

    //const result = await pool.request()
    //await pool.request()

    // 1. Buscar nome da procedure pelo menu
    const procRes = await pool.request()
      .query(`
      SELECT TOP 1 nome_procedure
      FROM meta_procedure_colunas
      WHERE cd_menu_id = ${cd_menu}
    `);

    if (procRes.recordset.length === 0) {
      return res.status(404).json({ error: 'Procedure não encontrada.' });
    }

    const procedure = procRes.recordset[0].nome_procedure;

    // 2. Executar procedure com os parâmetros enviados
    const request = await pool.request()

    for (const [key, value] of Object.entries(parametros)) {
      request.input(key, value);
    }

    const result = await request.execute(procedure);
    res.json(result.recordset);
  } catch (err) {
    console.error("Erro ao executar procedure:", err);
    res.status(500).json({ error: 'Erro ao executar procedure' });
  }
});

app.post("/api/lookup", async (req, res) => {

  //const { query } = req.body;
  const { query, banco: bancoBody, nm_banco_empresa } = req.body || {};

    if (!query || typeof query !== 'string') {
      return res.status(400).json({ error: "Corpo inválido: envie { query: 'SELECT ...' }" });
    }
   //
  

  // 👇 resolve banco de forma robusta: header → query → sessão → fallback
   // prioriza: header → querystring → body → sessão → fallback global
    const banco =
      req.headers['x-banco'] ||
      req.query?.banco ||
      bancoBody ||
      nm_banco_empresa ||
      req.session?.nm_banco ||
      `${nm_banco}`;

    if (!banco) {
      return res.status(400).json({ error: "Banco não informado (x-banco)." });
    }

     console.log("Banco usado:", banco);
   console.log("Query recebida:", query);  


  //console.log(query);

  try {

    //const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo
    //const pool = await getPool(banco);

    const pool = await getPool(banco.trim());
    const result = await pool.request().query(query);
    res.json(result.recordset);

    //console.log(result.recordset);

  } catch (err) {
    console.error("Erro no lookup:", err);
    res.status(500).json({ error: "Erro ao buscar dados da lookup." });
  }

});

app.post('/api/formulario-atributo', protegerRota, async (req, res) => {
  const payload = req.body; // Deve ser um array com os campos esperados

  if (!payload || typeof payload !== "object") {
    return res.status(400).json({ error: "Payload inválido." });
  }

  const jsonParam = '[' + JSON.stringify(payload).replace(/'/g, "''") + ']';

  //console.log(jsonParam);

  const pool = await getPool('EgisAdmin'); // usa o pool do banco certo

  //console.log(jsonParam);

  try {
    const result = await pool.request()
      .input('json', sql.NVarChar, jsonParam.replace(/'/g, "''"))
      .execute('pr_egis_formulario_atributo');
    //console.log(result.recordset);
    res.json(result.recordset);
  } catch (err) {
    console.error('Erro ao executar pr_formulario_atributo:', err);
    res.status(500).json({ error: err.message });
  }
});


app.post("/api/api-dados-form", protegerRota, async (req, res) => {
  
  let banco;
  
  banco =
        req.headers["x-banco"] ||             // dashboards externos
        req.query.banco ||                    // agenda externa
        req.session?.nm_banco ||              // dashboards internos (login)
        `${nm_banco}` ||
        null;

      console.log("🌐 Banco definido por header/query/sessão:", banco);

   //

  //const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo

  const pool = await getPool(`${banco}`); // usa o pool do banco certo

  try {
    const payload = req.body;

    if (!payload || typeof payload !== "object") {
      return res.status(400).json({ error: "Payload inválido." });
    }

    const jsonParam = '[' + JSON.stringify(payload).replace(/'/g, "''") + ']';

    console.log(jsonParam);

    const result = await pool.request().query(`
      EXEC pr_egis_api_crud_dados_especial N'${jsonParam}'
    `);

    //console.log(result.recordset);

    res.json({
      message: "✔️ Dados processados com sucesso.",
      dados: result.recordset
    });
  } catch (err) {
    console.error("❌ Erro na rota /api/api-dados-form:", err);
    res.status(500).json({ error: "Erro ao executar a procedure." });
  }
});

app.post('/api/tabela-registro-dados', protegerRota, async (req, res) => {

  const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo

  try {
    const payload = req.body;

    if (!payload || typeof payload !== "object") {
      return res.status(400).json({ error: "Payload inválido." });
    }

    const jsonParam = '[' + JSON.stringify(payload).replace(/'/g, "''") + ']';

    //console.log(jsonParam);

    const result = await pool.request().query(`
      EXEC pr_egis_pesquisa_tabela_registro N'${jsonParam}'
    `);

    res.json(result.recordset[0]); // ✅ retorna o objeto do registro

  } catch (err) {
    console.error("❌ Erro ao buscar dados do registro:", err);
    res.status(500).json({ error: "Erro ao buscar dados do registro" });
  }
});

//
// Utilitário: converter nome do mês para sigla em inglês (se necessário)
const mapSigla = {
  'JAN': 'Jan',
  'FEV': 'Feb',
  'MAR': 'Mar',
  'ABR': 'Apr',
  'MAI': 'May',
  'JUN': 'Jun',
  'JUL': 'Jul',
  'AGO': 'Aug',
  'SET': 'Sep',
  'OUT': 'Oct',
  'NOV': 'Nov',
  'DEZ': 'Dec'
};

app.get('/api/vendas', protegerRota, (req, res) => {
  res.json({
    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    valores: [1200, 1500, 1800, 1000, 1700, 2200]
  });
});


app.get('/api/vendasG', protegerRota, async (req, res) => {
  //  res.json({
  //    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
  //    valores: [1200, 1500, 1800, 1000, 1700, 2200]
  //  });
  //});
  const {
    modulo,
    parametro,
    usuario,
    inicio,
    fim
  } = req.query;

  //console.log(modulo);

  if (!modulo || !parametro || !usuario || !inicio || !fim) {
    return res.status(400).json({ erro: "Parâmetros incompletos na requisição." });
  }

  //console.log(req.query);

  try {
    //await sql.connect(dbConfig);
    //console.log(nm_banco);
    //console.log(req.session.nm_banco);
    const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo
    //const pool = await getPool(req.session.nm_banco);
    const request = pool.request();

    request
      .input('cd_modulo', sql.Int, parseInt(modulo))
      .input('cd_parametro', sql.Int, parseInt(200))
      .input('cd_usuario', sql.Int, parseInt(usuario))
      .input('dt_inicial', sql.VarChar, inicio)
      .input('dt_final', sql.VarChar, fim);

    const result = await request.query(`
  EXEC pr_processo_dashboard_modulos 
    @cd_modulo = @cd_modulo,
    @cd_parametro = @cd_parametro,
    @cd_usuario = @cd_usuario,
    @dt_inicial = @dt_inicial,
    @dt_final = @dt_final
`);

    // console.log(result);

    const data = result.recordset;

    const labels = [];
    const valores = [];

    data.forEach(row => {
      const sigla = row.sg_mes?.toUpperCase?.() || '';
      const label = mapSigla[sg_mes] || sigla || `M${row.nm_mes}`;
      labels.push(label);
      valores.push(parseFloat(row.vl_total));
    });

    await pool.close(); // ← FECHA CONEXÃO

    //  console.log(result.recordset);

    //res.json(result.recordset);
    //  res.json({
    //    labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    //    valores: [1200, 1500, 1800, 1000, 1700, 2200]
    //  });
    //});

    // Retorno no formato desejado
    res.json({
      labels,
      valores
    });


  } catch (err) {
    console.error("Erro SQL:", err);
    res.status(500).json({ erro: "Falha ao executar a procedure" });
  }
});


app.get('/session-info', (req, res) => {
  res.json({
    usuario: req.session?.usuario || null,
    nome: req.session?.nome || null,
    perfil: req.session?.perfil || null
  });
});

app.get('/atividades', protegerRota, (req, res) => {
  res.sendFile(path.join(__dirname, 'views/atividades.html'));
});

app.get('/api/processos-dashboard', protegerRota, async (req, res) => {
  const {
    modulo,
    parametro,
    usuario,
    inicio,
    fim
  } = req.query;

  //console.log(modulo);

  if (!modulo || !parametro || !usuario || !inicio || !fim) {
    return res.status(400).json({ erro: "Parâmetros incompletos na requisição." });
  }

  // console.log(req.query);

  try {
    //await sql.connect(dbConfig);
    //console.log(nm_banco);
    //console.log(req.session.nm_banco);
    const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo
    //const pool = await getPool(req.session.nm_banco);
    const request = pool.request();

    request
      .input('cd_modulo', sql.Int, parseInt(modulo))
      .input('cd_parametro', sql.Int, parseInt(parametro))
      .input('cd_usuario', sql.Int, parseInt(usuario))
      .input('dt_inicial', sql.VarChar, inicio)
      .input('dt_final', sql.VarChar, fim);

    const result = await request.query(`
    EXEC pr_processo_dashboard_modulos 
      @cd_modulo = @cd_modulo,
      @cd_parametro = @cd_parametro,
      @cd_usuario = @cd_usuario,
      @dt_inicial = @dt_inicial,
      @dt_final = @dt_final
  `);

    //  console.log(result);

    await pool.close(); // ← FECHA CONEXÃO
    res.json(result.recordset);
  } catch (err) {
    console.error("Erro SQL:", err);
    res.status(500).json({ erro: "Falha ao executar a procedure" });
  }
});


app.post('/api/payload-tabela', protegerRota, async (req, res) => {

  const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo

  try {
    const payload = req.body;

    if (!payload || typeof payload !== "object") {
      return res.status(400).json({ error: "Payload inválido." });
    }

    const jsonParam = '[' + JSON.stringify(payload).replace(/'/g, "''") + ']';

    //console.log(jsonParam);

    const result = await pool.request().query(`
      EXEC pr_egis_payload_tabela N'${jsonParam}'
    `);

    res.json(result.recordset); // ✅ retorna o objeto do registro

  } catch (err) {
    console.error("❌ Erro ao buscar dados do registro:", err);
    res.status(500).json({ error: "Erro ao buscar dados do registro" });
  }
});

app.post('/api/catalogo-relatorio', protegerRota, async (req, res) => {

  const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo

  try {
    const payload = req.body;

    // console.log(payload);

    if (!payload || typeof payload !== "object") {
      return res.status(400).json({ error: "Payload inválido." });
    }

    const jsonParam = '[' + JSON.stringify(payload).replace(/'/g, "''") + ']';

    console.log(jsonParam);

    const result = await pool.request().query(`
      EXEC pr_egis_modulo_catalogo_relatorio N'${jsonParam}'
    `);

    console.log(result.recordset);

    res.json(result.recordset); // ✅ retorna o objeto do registro

  } catch (err) {
    console.error("❌ Erro ao buscar dados do registro:", err);
    res.status(500).json({ error: "Erro ao buscar dados do registro" });
  }
});

app.post('/api/menu-importacao', protegerRota, async (req, res) => {

  const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo

  try {
    const payload = req.body;

    // console.log(payload);

    if (!payload || typeof payload !== "object") {
      return res.status(400).json({ error: "Payload inválido." });
    }

    const jsonParam = '[' + JSON.stringify(payload).replace(/'/g, "''") + ']';

    console.log(jsonParam);

    const result = await pool.request().query(`
      EXEC pr_egis_importacao_dados N'${jsonParam}'
    `);

    console.log(result.recordset);

    res.json(result.recordset); // ✅ retorna o objeto do registro

  } catch (err) {
    console.error("❌ Erro ao buscar dados do registro:", err);
    res.status(500).json({ error: "Erro ao buscar dados do registro" });
  }
});

app.get('/api/usuarios-logados', protegerRota, async (req, res) => {
  try {

    const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo

    const payload = [{
      cd_parametro: "0",
      cd_usuario: req.session.cd_usuario // usuário atual logado
    }];

    const result = await pool.request()
      .input('json', sql.NVarChar, JSON.stringify(payload))
      .execute('pr_egis_usuario_logado');

    res.json(result.recordset);

  } catch (err) {
    console.error("❌ Erro ao buscar usuários logados:", err);
    res.status(500).json({ error: 'Erro ao buscar usuários logados' });
  }
});

// Usar as rotas
app.use('/api/caixa-logistica', caixaLogisticaRoutes);
///////////////////////////////////////////////////////
app.use('/api/veloe', veloeRoutes);
///////////////////////////////////////////////////////
app.use('/api/serasa', serasaRoutes);
///////////////////////////////////////////////////////
app.use('/api/monitor', monitorRoutes);
///////////////////////////////////////////////////////
app.use('/api/chat', chatRoutes);
///////////////////////////////////////////////////////
app.use('/api/entregas', logisticaRoutes);
///////////////////////////////////////////////////////
app.use('/api/financeiro', financeiroRoutes);
///////////////////////////////////////////////////////
app.use('/api/nfe', nfeRoutes);
///////////////////////////////////////////////////////
app.use('/api/cnpja', cnpjDocsRoutes);
/////////////////////////////////////////////////////////////
app.use('/api/validacao', validacaoRoutes);
/////////////////////////////////////////////////////////////\
app.use('/api/relatorio', relatorioRoutes);
/////////////////////////////////////////////////////////////
app.use('/api/dfe', dfeRoutes);
/////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////

//Rotas
// Redirecionamento amigável para a tela inicial da logística
app.get('/logistica', protegerRota, (req, res) => {
  // console.log(req.session);
  res.redirect('/logistica/index.html');
});

///////////////////////////////////////////////////////
// RELATÓRIO///
//////////////
const PDFDocument = require("pdfkit");

app.post("/api/relatorio", protegerRota, async (req, res) => {
  const { cd_menu, cd_usuario, dados } = req.body;

  if (!Array.isArray(dados) || dados.length === 0) {
    return res.status(400).send("Nenhum dado recebido para gerar o relatório.");
  }

  try {
    const doc = new PDFDocument();
    const buffers = [];

    doc.on("data", buffers.push.bind(buffers));
    doc.on("end", () => {
      const pdfData = Buffer.concat(buffers);
      res.setHeader("Content-Type", "application/pdf");
      res.setHeader("Content-Disposition", "inline; filename=relatorio.pdf");
      res.send(pdfData);
    });

    doc.fontSize(16).text(`Relatório de Dados (Menu ${cd_menu})`, { align: "center" });
    doc.moveDown();

    const colunas = Object.keys(dados[0]);
    doc.fontSize(12).text(colunas.join(" | "));
    doc.moveDown();

    dados.forEach(linha => {
      const linhaTexto = colunas.map(col => linha[col] ?? "").join(" | ");
      doc.text(linhaTexto);
    });

    doc.end();
  } catch (err) {
    console.error("❌ Erro ao gerar PDF:", err);
    res.status(500).send("Erro ao gerar relatório.");
  }
});

const fs = require("fs");
const uploadsPath = path.join(__dirname, "public/uploads");

// Cria a pasta uploads se não existir
if (!fs.existsSync(uploadsPath)) {
  fs.mkdirSync(uploadsPath, { recursive: true });
}

const multer = require('multer');

// configuração de armazenamento
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, path.join(__dirname, 'public/uploads'));
  },
  filename: function (req, file, cb) {
    const nomeUnico = Date.now() + '-' + file.originalname;
    cb(null, nomeUnico);
  }
});

const upload = multer({ storage });

// rota para upload de arquivos
app.post("/api/upload-arquivo", upload.single("arquivo"), (req, res) => {
  if (!req.file) {
    return res.status(400).json({ erro: "Nenhum arquivo foi enviado." });
  }

  const nomeArquivo = req.file.filename;
  const url_publica = `http://34.237.139.201/uploads/${nomeArquivo}`;

  res.json({ sucesso: true, url_publica });

});


//EXCEL //

app.post('/api/importar-excel-para-tabela', protegerRota, async (req, res) => {

  try {
    const { nome_tabela, dados } = req.body;

    //console.log(req.body);

    if (!nome_tabela || !Array.isArray(dados) || dados.length === 0) {
      return res.status(400).json({ erro: "Dados ou nome da tabela inválidos." });
    }

    const pool = await getPool(`${nm_banco}`);

    //const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo

    // Apagar tabela se existir
    await pool.request().query(`
      IF OBJECT_ID('${nome_tabela}', 'U') IS NOT NULL
        DROP TABLE ${nome_tabela}
    `);

    // Gerar DDL da nova tabela
    const colunas = Object.keys(dados[0]);
    const ddlCampos = colunas.map(col => `[${col}] NVARCHAR(MAX)`).join(", ");
    await pool.request().query(`
      CREATE TABLE ${nome_tabela} (${ddlCampos})
    `);

    // Inserir os dados
    for (const row of dados) {
      const campos = Object.keys(row).map(col => `[${col}]`).join(", ");
      const valores = Object.values(row).map(val =>
        val === null || val === undefined
          ? 'NULL'
          : `'${val.toString().replace(/'/g, "''")}'`
      ).join(", ");
      const insertSQL = `INSERT INTO ${nome_tabela} (${campos}) VALUES (${valores})`;
      await pool.request().query(insertSQL);
    }

    res.json({ mensagem: `✅ Dados importados na tabela ${nome_tabela}` });

  } catch (err) {
    console.error("❌ Erro ao importar para banco:", err);
    res.status(500).json({ erro: "Erro ao importar dados para o banco." });
  }
});

/////////
app.post('/apiant/exec/:procedure', protegerRota, async (req, res) => {
  const procedure = req.params.procedure;
  const parametros = req.body;

  console.log(req.body);

  try {
    const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo
    const request = pool.request();

    if (parametros) {
      for (const [key, value] of Object.entries(parametros)) {
        request.input(key, value);
      }
    }

    const result = await pool.request().
      execute(procedure);

    res.json(result.recordset);

    console.log(result.recordset);

  } catch (err) {
    console.error('Erro na execução da procedure:', err);
    res.status(500).json({ error: err.message });
  }
});


/////////////////////////////
//kanban
/////////////////////////////////////////////////////////////////////////////
app.post('/api/pipeline-modulo', protegerRota, async (req, res) => {

  const pool = await getPool(`${nm_banco}`); // usa o pool do banco certo

  try {
    const payload = req.body;

    // console.log(payload);

    if (!payload || typeof payload !== "object") {
      return res.status(400).json({ error: "Payload inválido." });
    }

    const jsonParam = '[' + JSON.stringify(payload).replace(/'/g, "''") + ']';

    console.log(jsonParam);

    const result = await pool.request().query(`
      EXEC pr_movimento_modulo_pipeline N'${jsonParam}'
    `);

    console.log(result.recordset);

    res.json(result.recordset); // ✅ retorna o objeto do registro

  } catch (err) {
    console.error("❌ Erro ao buscar dados do registro:", err);
    res.status(500).json({ error: "Erro ao buscar dados do registro" });
  }
});

//GRAFICO

app.get('/api/atributos-grafico/:cd_menu', protegerRota, async (req, res) => {
  const { cd_menu } = req.params;

  try {
    const pool = await getPool(`${nm_banco}`);

    const result = await pool.request()
      .input('cd_menu', sql.Int, parseInt(cd_menu))
      .query(`
        SELECT 
          cd_menu,
          nm_atributo,
          tipo_grafico,
          agrupador_base,
          cor,
          ordem
        FROM egisadmin.dbo.atributo_grafico
        WHERE ativo = 1 AND cd_menu = @cd_menu
        ORDER BY ordem
      `);

    res.json(result.recordset);

  } catch (err) {
    console.error("Erro ao buscar atributos de gráfico:", err);
    res.status(500).json({ error: "Erro ao buscar atributos de gráfico." });
  }
});

app.post('/api/salvar-atributos-grafico', protegerRota, async (req, res) => {
  const { cd_menu, atributos } = req.body;
  if (!cd_menu || !Array.isArray(atributos)) {
    return res.status(400).json({ error: "Dados inválidos" });
  }

  try {
    // const pool = await getPool(`${nm_banco}`);
    const pool = await getPool('egisAdmin');

    // Limpa registros antigos
    await pool.request()
      .input('cd_menu', sql.Int, cd_menu)
      .query('DELETE FROM atributo_grafico WHERE cd_menu = @cd_menu');

    // Insere os novos
    for (const attr of atributos) {
      await pool.request()
        .input('cd_menu', sql.Int, cd_menu)
        .input('nm_atributo', sql.VarChar, attr.nm_atributo)
        .input('tipo_grafico', sql.VarChar, attr.tipo_grafico)
        .input('agrupador_base', sql.VarChar, attr.agrupador_base)
        .input('cor', sql.VarChar, attr.cor)
        .input('ordem', sql.Int, attr.ordem || 1)
        .input('ativo', sql.Bit, 1)
        .query(`
          INSERT INTO atributo_grafico (cd_menu, nm_atributo, tipo_grafico, agrupador_base, cor, ordem, ativo)
          VALUES (@cd_menu, @nm_atributo, @tipo_grafico, @agrupador_base, @cor, @ordem, @ativo)
        `);
    }

    res.json({ message: "✅ Configuração salva com sucesso!" });
  } catch (err) {
    console.error("Erro ao salvar gráfico:", err);
    res.status(500).json({ error: "Erro ao salvar configuração" });
  }
});

app.post('/api/menu-processo', protegerRota, async (req, res) => {

  const pool = await getPool('egisAdmin');

  try {
    const payload = req.body;

    // console.log(payload);

    if (!payload || typeof payload !== "object") {
      return res.status(400).json({ error: "Payload inválido." });
    }

    const jsonParam = '[' + JSON.stringify(payload).replace(/'/g, "''") + ']';

    console.log(jsonParam);

    const result = await pool.request().query(`
        EXEC pr_egis_menu_processo N'${jsonParam}'
      `);

    console.log(result.recordset);

    if (!result || result.length === 0) {
      return res.json({ sucesso: false, result: [] });
    }

    const resposta = {
      sucesso: true,
      processos: result.recordset.map(p => ({
        cd_menu_acesso: p.cd_menu_acesso,
        nm_processo: p.nm_processo,
        nm_caminho_pagina: p.nm_caminho_pagina
      }))
    };

    // console.log(resposta);

    res.json(resposta); // ✅ retorna o objeto do registro

  } catch (err) {
    console.error("❌ Erro ao buscar dados do registro:", err);
    res.status(500).json({ error: "Erro ao buscar dados do registro" });
  }
});

app.post('/api/validar-script', protegerRota, async (req, res) => {
  const { script } = req.body;

  if (!script || typeof script !== "string") {
    return res.status(400).json({ error: "Script inválido." });
  }

  try {
    const pool = await getPool(`${nm_banco}`); // Banco da sessão atual
    const result = await pool.request().query(script);
    res.json(result.recordset); // retorna array (vazio ou com dados)
  } catch (err) {
    console.error("❌ Erro ao validar script:", err);
    res.status(500).json({ error: "Erro ao executar script de validação." });
  }
});


////////////////////////////////////////////////////////////////////////////
//exec de procedure
////////

app.post('/api/exec/:procedure', protegerRota, async (req, res) => {
  const procedure = req.params.procedure.toLowerCase();
  const payload = req.body;

  console.log(`${nm_banco}`);

  try {
    //const pool = await getPool(`${nm_banco}`);

    let banco;
    banco = `${nm_banco}`;

    const origemServico = req.headers["x-servico-fila"];

    if (origemServico === "validacaoproposta" || origemServico === "egiscnpj") {
      banco = req.body?.[0]?.nm_banco_empresa || "EGISCNPJ";
      console.log("🌐 Banco definido pelo serviço:", banco);
    } else {
      banco =
        req.headers["x-banco"] ||             // dashboards externos
        req.query.banco ||                    // agenda externa
        req.session?.nm_banco ||              // dashboards internos (login)
        `${nm_banco}` ||
        null;

      console.log("🌐 Banco definido por header/query/sessão:", banco);

    }

    if (!banco) {
      console.error("❌ Banco de dados não definido.");
      return res.status(400).json({ error: "Banco de dados não definido." });
    }

    //

    console.log("🌐 Banco usado:", banco);


    //

    const pool = await getPool(banco);

    //

    const request = pool.request();

    // Detecta JSON embutido no array
    let isJson = false;
    let parametros = null;
    //

    if (Array.isArray(payload) && payload.length > 0) {
      const primeiro = payload[0];
      isJson = primeiro.ic_json_parametro === "S";
      parametros = payload;
    } else if (typeof payload === "object") {
      isJson = payload.ic_json_parametro === "S";
      parametros = payload;
    }

    if (isJson) {
      // Envia como string JSON para procedure com @json
      request.input("json", JSON.stringify(parametros));
    } else {
      for (const [key, value] of Object.entries(parametros)) {
        if (key !== "ic_json_parametro") {
          request.input(key, value);
        }
      }
    }

    const result = await request.execute(procedure);
    res.json(result.recordset);

    console.log('retorno sql: ', result.recordset);

  } catch (err) {
    console.error("Erro na execução da procedure:", err);
    res.status(500).json({ error: err.message });
  }
});

/////////

app.post('/api/exec-cnpj/:procedure', protegerRota, async (req, res) => {
  const procedure = req.params.procedure.toLowerCase();
  const payload = req.body;

  console.log(`${nm_banco}`);

  try {
    const pool = await getPool(`${nm_banco}`);
    const request = pool.request();

    // Detecta JSON embutido no array
    let isJson = false;
    let parametros = null;
    //

    if (Array.isArray(payload) && payload.length > 0) {
      const primeiro = payload[0];
      isJson = primeiro.ic_json_parametro === "S";
      parametros = payload;
    } else if (typeof payload === "object") {
      isJson = payload.ic_json_parametro === "S";
      parametros = payload;
    }

    if (isJson) {
      // Envia como string JSON para procedure com @json
      request.input("json", JSON.stringify(parametros));
    } else {
      for (const [key, value] of Object.entries(parametros)) {
        if (key !== "ic_json_parametro") {
          request.input(key, value);
        }
      }
    }

    const result = await request.execute(procedure);
    res.json(result.recordset);

    console.log('retorno sql: ', result.recordset);

  } catch (err) {
    console.error("Erro na execução da procedure:", err);
    res.status(500).json({ error: err.message });
  }
});


// executar-exe.js

// Caminho base fixo (segurança)
const CAMINHO_BASE = 'C:\\GBS-EGIS\\EXE\\';

// 🔐 Segurança extra: impedir comandos maliciosos
function sanitizar(nome) {
  return nome.replace(/[^a-zA-Z0-9_.-]/g, '');
}

// Endpoint para executar .exe


app.post('/executar', (req, res) => {
  const nomeModulo = sanitizar(req.body.nomeModulo || '');
  const args = req.body.parametros || '';

  if (!nomeModulo.endsWith('.exe')) {
    return res.status(400).send('Nome de módulo inválido.');
  }

  const caminhoCompleto = `${CAMINHO_BASE}${nomeModulo}`;
  console.log(`🟡 Executando: ${caminhoCompleto} ${args}`);

  exec(`"${caminhoCompleto}" ${args}`, (err, stdout, stderr) => {
    if (err) {
      console.error('❌ Erro ao executar:', err);
      return res.status(500).send(`Erro: ${err.message}`);
    }

    console.log('✅ Executado com sucesso:', stdout);
    res.send(`Executado: ${stdout}`);

  });
});


/*
app.post('/executar', (req, res) => {
  const nomeModulo = sanitizar(req.body.nomeModulo || '');

  if (!nomeModulo.endsWith('.exe')) {
    return res.status(400).send('Nome de módulo inválido.');
  }

  const caminhoCompleto = `${CAMINHO_BASE}${nomeModulo}`;
  console.log(`🟡 Executando: ${caminhoCompleto}`);

  exec(`"${caminhoCompleto}"`, (err, stdout, stderr) => {
    if (err) {
      console.error('❌ Erro ao executar:', err);
      return res.status(500).send(`Erro: ${err.message}`);
    }

    console.log('✅ Executado com sucesso:', stdout);

    res.send(`Executado: ${stdout}`);

  });
});
*/

//app.listen(PORT, () => {
//  console.log(`🟢 Servidor rodando na porta ${PORT}`);
//});


//////////////////////////////////////////////////////////////////////////////////
//SEMPRE NO FINAL
/////////////////
//app.use((req, res) => {
//  res.status(404).sendFile(path.join(__dirname, '..', 'public', 'erro.html'));
//});

app.use((req, res, next) => {
  const cleanedPath = req.path.replace(/\/+$/, ''); // remove / final
  if (cleanedPath === '' || cleanedPath === '/index' || cleanedPath === '/index.html') {
    return res.sendFile(path.join(__dirname, '..', 'public', 'login.html'));
  }

  // Para debugar: mostrar o path vindo
  console.log('404 PATH:', req.path);
  res.status(404).sendFile(path.join(__dirname, '..', 'public', 'erro.html'));
});

// Inicia o servidor
//app.listen(PORT, () => {
//  console.log(`Servidor rodando em http://localhost:${PORT}`);
//});

module.exports = app; // permite que o server.js use


