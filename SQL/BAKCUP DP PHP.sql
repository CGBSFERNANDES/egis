// IDE
try {
    $ide = safeConvert($json['ide'] ?? null, 'ide');
    $nfe->tagide($ide);
    //file_put_contents(__DIR__ . '/debug-tagide.log', 'ok');
    if (!$nfe->tagide($ide)) registrarErroTag('tagide', __LINE__);
} catch (Exception $e) {
    file_put_contents(__DIR__ . '/debug-tagide.log', 'Erro: ' . $e->getMessage());
}

// EMIT
try {
    $emit = safeConvert($json['emit'] ?? null, 'emit');
    $nfe->tagemit($emit);
    if (!$nfe->tagemit($emit)) registrarErroTag('tagemit', __LINE__);
} catch (Exception $e) {
    file_put_contents(__DIR__ . '/debug-tagemit.log', $e->getMessage());
}

// enderEmit
try {
    if (isset($emit->enderEmit)) {
        $enderEmit = safeConvert($emit->enderEmit, 'enderEmit');
        $nfe->tagenderEmit($enderEmit);
    }
} catch (Exception $e) {
    file_put_contents(__DIR__ . '/debug-tagenderemit.log', $e->getMessage());
}

// PRODUTOS
foreach ($json['produtos'] ?? [] as $i => $prodRaw) {
    try {
        $prod = safeConvert($prodRaw, "produto{$i}");
        $nfe->tagprod($prod);
        if (isset($prod->ICMS)) {
            $nfe->tagICMS(safeConvert($prod->ICMS, "ICMS{$i}"));
        }
        if (isset($prod->PIS)) {
            $nfe->tagPIS(safeConvert($prod->PIS, "PIS{$i}"));
        }
        if (isset($prod->COFINS)) {
            $nfe->tagCOFINS(safeConvert($prod->COFINS, "COFINS{$i}"));
        }
    } catch (Exception $e) {
        file_put_contents(__DIR__ . "/debug-tagprod-{$i}.log", $e->getMessage());
    }
}

// TOTAL
try {
    $total = safeConvert($json['total'] ?? null, 'total');
    $nfe->tagICMSTot($total);
} catch (Exception $e) {
    file_put_contents(__DIR__ . '/debug-tagtotal.log', $e->getMessage());
}

// TRANSP
try {
    if (!empty($json['transp'])) {
        $transp = safeConvert($json['transp'], 'transp');
        $nfe->tagtransp($transp);
    }
} catch (Exception $e) {
    file_put_contents(__DIR__ . '/debug-tagtransp.log', $e->getMessage());
}

// PAG
try {
    $pagRaw = $json['pag'] ?? null;
    if (!empty($pagRaw)) {
        $pag = is_string($pagRaw) ? json_decode($pagRaw) : arr2obj($pagRaw);
        $nfe->tagpag($pag);
        if (isset($pag->detPag)) {
            $detPagArr = is_array($pag->detPag) ? $pag->detPag : [$pag->detPag];
            foreach ($detPagArr as $d) {
                $det = is_array($d) ? (object)$d : $d;
                $nfe->tagdetPag($det);
            }
        }
    }
} catch (Exception $e) {
    file_put_contents(__DIR__ . '/debug-tagpag.log', $e->getMessage());
}



/*
    //
    $infNFe    = json_decode($json['infNFe'], true);
    $nfe->taginfNFe($infNFe);
    //
    
    // ------------------------------------------------------------------
    // ide
    // ------------------------------------------------------------------
    if (empty($json['ide'])) {
        throw new Exception('Bloco ide obrigatório ausente.');
    }
    //$ide = arr2obj($json['ide']);
    //$ide = is_string($json['ide']) ? json_decode($json['ide']) : arr2obj($json['ide']);
    //
    //$nfe->tagide($ide);
    
    // ------------------------------------------------------------------
    // ide - Identificação da NFC-e
    // ------------------------------------------------------------------

    $ideRaw = $json['ide'] ?? null;

    // Loga sempre o conteúdo recebido
    //file_put_contents(__DIR__ . '/debug-ide.log', print_r($ideRaw, true));
    //

    try {
    // Se veio como string JSON
    if (is_string($ideRaw)) {
        $ideDecoded = json_decode($ideRaw);
        if (json_last_error() !== JSON_ERROR_NONE || !is_object($ideDecoded)) {
            throw new Exception('Erro ao decodificar campo ide: ' . json_last_error_msg());
        }
        $ide = $ideDecoded;

    // Se já veio como array
    } elseif (is_array($ideRaw)) {
        $ide = arr2obj($ideRaw);

    // Se já for objeto
    } elseif (is_object($ideRaw)) {
        $ide = $ideRaw;

    // Caso contrário: erro
    } else {
        throw new Exception("Campo 'ide' inválido ou ausente.");
    }

    // Tenta gerar a tag
    $nfe->tagide($ide);

    } catch (Exception $e) {
       // Loga o erro específico
       //file_put_contents(__DIR__ . '/debug-ide-erro.log', $e->getMessage() . "\n" . print_r($ideRaw, true));
       throw new Exception("Erro ao processar campo 'ide': " . $e->getMessage());
    }

    // ------------------------------------------------------------------
    // emit
    // ------------------------------------------------------------------
    if (empty($json['emit'])) {
        throw new Exception('Bloco emit obrigatório ausente.');
    }

    // ------------------------------------------------------------------
    // emit - Emitente da NFC-e
    // ------------------------------------------------------------------

    $emitRaw = $json['emit'] ?? null;

    try {
    if (is_string($emitRaw)) {
        $emitDecoded = json_decode($emitRaw);
        if (json_last_error() !== JSON_ERROR_NONE || !is_object($emitDecoded)) {
            throw new Exception('Erro ao decodificar campo emit: ' . json_last_error_msg());
        }
        $emit = $emitDecoded;
    } elseif (is_array($emitRaw)) {
        $emit = arr2obj($emitRaw);
    } elseif (is_object($emitRaw)) {
        $emit = $emitRaw;
    } else {
        throw new Exception("Campo 'emit' inválido ou ausente.");
    }

    $nfe->tagemit($emit);

    // Trata o endereço também (se existir)

    if (isset($emit->enderEmit)) {
        $endEmitRaw = $emit->enderEmit;
        if (is_string($endEmitRaw)) {
            $enderEmit = json_decode($endEmitRaw);
        } elseif (is_array($endEmitRaw)) {
            $enderEmit = (object)$endEmitRaw;
        } else {
            $enderEmit = $endEmitRaw;
        }
        $nfe->tagenderEmit($enderEmit);
    }

} catch (Exception $e) {
    throw new Exception("Erro ao processar campo 'emit': " . $e->getMessage());
}

    // Guarda CRT p/ uso em impostos
    $CRT = (int)($emit->CRT ?? 3); // 1/2 Simples; 3 Normal

    // ------------------------------------------------------------------
    // dest (NFC-e pode ser consumidor final identificado ou não)
    // ------------------------------------------------------------------
    if (!empty($json['dest'])) {
        $dest = arr2obj($json['dest']);
        if (isset($dest->enderDest)) {
            $enderDest = is_array($dest->enderDest) ? (object)$dest->enderDest : $dest->enderDest;
            $nfe->tagenderDest($enderDest);
        }
        $nfe->tagdest($dest);
    }

    // ------------------------------------------------------------------
    // Produtos + Impostos
    // ------------------------------------------------------------------
    if (!empty($json['produtos']) && is_array($json['produtos'])) {
        foreach ($json['produtos'] as $produto) {
          if (!isset($produto['item']) && !isset($produto['nItem'])) {
            throw new Exception("Produto sem 'item' ou 'nItem' definido.");
          }


            // Normaliza produto
            $prod = is_array($produto) ? (object)$produto : $produto;

            // 1) Produto (tag <prod>)
            $nfe->tagprod($prod);

            // 2) Imposto wrapper (tag <imposto>)
            //    Algumas UF exigem vTotTrib; se vier no JSON já deixa
            $imp = new stdClass();
            $imp->item = $prod->item ?? $prod->nItem ?? null; // Make exige item
            if (isset($prod->vTotTrib)) { $imp->vTotTrib = num($prod->vTotTrib,2); }
            $nfe->tagimposto($imp);

            // ---------------------------------------------------------
            // 3) ICMS ou ICMSSN conforme CRT
            // ---------------------------------------------------------
            $icmsIn = $prod->ICMS ?? null; // pode ser array/json/texto
            if (is_string($icmsIn)) { $icmsIn = json_decode($icmsIn); }
            elseif (is_array($icmsIn)) { $icmsIn = (object)$icmsIn; }

            if ($CRT == 1 || $CRT == 2) {
                // ---------------- Simples Nacional -----------------
                $icmssn = new stdClass();
                $icmssn->item = $imp->item; // mesmo item
                $icmssn->orig = v($icmsIn,'orig',0);
                // tenta identificar CSOSN (pode vir CSOSN ou csosn; se vier CST 102, converte)
                $csosn = v($icmsIn,'CSOSN');
                if ($csosn === null) { $csosn = v($icmsIn,'csosn'); }
                if ($csosn === null) {
                    // tentativa: se houver CST 102, 103 etc
                    $cstTmp = v($icmsIn,'CST');
                    if (in_array($cstTmp,['101','102','103','201','202','203','300','400','500','900'])) {
                        $csosn = $cstTmp;
                    }
                }
                if ($csosn === null) { $csosn = '102'; } // fallback seguro
                $icmssn->CSOSN = $csosn;

                // Campos adicionais de acordo com CSOSN
                switch ($csosn) {
                    case '101':
                        $icmssn->pCredSN     = num(v($icmsIn,'pCredSN','0'),4);
                        $icmssn->vCredICMSSN = num(v($icmsIn,'vCredICMSSN','0'),2);
                        break;
                    case '900':
                        $icmssn->modBC = v($icmsIn,'modBC',3);
                        $icmssn->vBC   = num(v($icmsIn,'vBC','0'),2);
                        $icmssn->pICMS = num(v($icmsIn,'pICMS','0'),4);
                        $icmssn->vICMS = num(v($icmsIn,'vICMS','0'),2);
                        // se houver ST retida etc pode mapear aqui
                        break;
                    case '500':
                        $icmssn->vBCSTRet   = num(v($icmsIn,'vBCSTRet','0'),2);
                        $icmssn->vICMSSTRet = num(v($icmsIn,'vICMSSTRet','0'),2);
                        break;
                    // demais CSOSN (102,103,300,400, etc) não exigem campos adicionais
                }
                $nfe->tagICMSSN($icmssn);

            } else {
                // ---------------- Regime Normal --------------------
                $icms = new stdClass();
                $icms->item  = $imp->item;
                $icms->orig  = v($icmsIn,'orig',0);
                $icms->CST   = v($icmsIn,'CST','00');
                $icms->modBC = v($icmsIn,'modBC',3);
                $icms->vBC   = num(v($icmsIn,'vBC','0'),2);
                $icms->pICMS = num(v($icmsIn,'pICMS','0'),4);
                $icms->vICMS = num(v($icmsIn,'vICMS','0'),2);
                $nfe->tagICMS($icms);
            }

            // ---------------------------------------------------------
            // 4) PIS
            // ---------------------------------------------------------
            if (isset($prod->PIS)) {
                $pisIn = $prod->PIS;
                if (is_string($pisIn)) { $pisIn = json_decode($pisIn); }
                elseif (is_array($pisIn)) { $pisIn = (object)$pisIn; }
                $pis = new stdClass();
                $pis->item = $imp->item;
                $pis->CST  = v($pisIn,'CST','07');
                // Layout reduzido: uso de PISOutr
                $pis->vBC  = num(v($pisIn,'vBC','0'),2);
                $pis->pPIS = num(v($pisIn,'pPIS','0'),4);
                $pis->vPIS = num(v($pisIn,'vPIS','0'),2);
                $nfe->tagPIS($pis);
            }

            // ---------------------------------------------------------
            // 5) COFINS
            // ---------------------------------------------------------
            if (isset($prod->COFINS)) {
                $cofIn = $prod->COFINS;
                if (is_string($cofIn)) { $cofIn = json_decode($cofIn); }
                elseif (is_array($cofIn)) { $cofIn = (object)$cofIn; }
                $cof = new stdClass();
                $cof->item    = $imp->item;
                $cof->CST     = v($cofIn,'CST','07');
                $cof->vBC     = num(v($cofIn,'vBC','0'),2);
                $cof->pCOFINS = num(v($cofIn,'pCOFINS','0'),4);
                $cof->vCOFINS = num(v($cofIn,'vCOFINS','0'),2);
                $nfe->tagCOFINS($cof);
            }
        }
    }

    // ------------------------------------------------------------------
    // Totais (vProd, vNF ...)
    // ------------------------------------------------------------------
    if (empty($json['total'])) { throw new Exception('Bloco total obrigatório.'); }

    //$total = arr2obj($json['total']);
    //$nfe->tagICMSTot($total);
    // ------------------------------------------------------------------
    // total - Totais da nota
    // ------------------------------------------------------------------

    $totalRaw = $json['total'] ?? null;
    //file_put_contents(__DIR__ . '/debug-total.log', print_r($totalRaw, true));

    try {
    if (is_string($totalRaw)) {
        $totalDecoded = json_decode($totalRaw);
        if (json_last_error() !== JSON_ERROR_NONE || !is_object($totalDecoded)) {
            throw new Exception('Erro ao decodificar campo total: ' . json_last_error_msg());
        }
        $total = $totalDecoded;
    } elseif (is_array($totalRaw)) {
        $total = arr2obj($totalRaw);
    } elseif (is_object($totalRaw)) {
        $total = $totalRaw;
    } else {
        throw new Exception("Campo 'total' inválido ou ausente.");
    }

    $nfe->tagICMSTot($total);

} catch (Exception $e) {
    //file_put_contents(__DIR__ . '/debug-total-erro.log', $e->getMessage() . \"\\n\" . print_r($totalRaw, true));
    throw new Exception("Erro ao processar campo 'total': " . $e->getMessage());
}


// ------------------------------------------------------------------
// transp - Transportadora
// ------------------------------------------------------------------

$transpRaw = $json['transp'] ?? null;

try {
    if (!empty($transpRaw)) {
        if (is_string($transpRaw)) {
            $transpDecoded = json_decode($transpRaw);
            if (json_last_error() !== JSON_ERROR_NONE || !is_object($transpDecoded)) {
                throw new Exception('Erro ao decodificar campo transp: ' . json_last_error_msg());
            }
            $transp = $transpDecoded;
        } elseif (is_array($transpRaw)) {
            $transp = arr2obj($transpRaw);
        } elseif (is_object($transpRaw)) {
            $transp = $transpRaw;
        } else {
            throw new Exception("Campo 'transp' inválido.");
        }

        $nfe->tagtransp($transp);
    }

} catch (Exception $e) {
    //file_put_contents(__DIR__ . '/debug-transp-erro.log', $e->getMessage() . \"\\n\" . print_r($transpRaw, true));
    throw new Exception("Erro ao processar campo 'transp': " . $e->getMessage());
}


    
    // ------------------------------------------------------------------
    // Pagamentos
    // ------------------------------------------------------------------

    $pagRaw = $json['pag'] ?? null;


    try {
    if (!empty($pagRaw)) {
        if (is_string($pagRaw)) {
            $pagDecoded = json_decode($pagRaw);
            if (json_last_error() !== JSON_ERROR_NONE || !is_object($pagDecoded)) {
                throw new Exception('Erro ao decodificar campo pag: ' . json_last_error_msg());
            }
            $pag = $pagDecoded;
        } elseif (is_array($pagRaw)) {
            $pag = arr2obj($pagRaw);
        } elseif (is_object($pagRaw)) {
            $pag = $pagRaw;
        } else {
            throw new Exception("Campo 'pag' inválido.");
        }

        $nfe->tagpag($pag);

        if (isset($pag->detPag)) {
            $detPagArr = is_array($pag->detPag) ? $pag->detPag : [$pag->detPag];
            foreach ($detPagArr as $d) {
                $det = is_array($d) ? (object)$d : $d;
                $nfe->tagdetPag($det);
            }
        }
    }

   } catch (Exception $e) {  
    throw new Exception("Erro ao processar campo 'pag': " . $e->getMessage());
}

   //info Adicional

    // ------------------------------------------------------------------
    // Gera XML
    // ------------------------------------------------------------------

// ------------------------------------------------------------------
// Bloco de TAGs com tratamento de erro e debug
// ------------------------------------------------------------------


    try {

$xmlParcial = $nfe->dom->saveXML();

file_put_contents(__DIR__ . '/debug-etapas.log', implode("\n", [
    'Etapas verificadas:',
    'ide: ' . (strpos($xmlParcial, '<ide>') !== false ? 'ok' : 'faltando'),
    'emit: ' . (strpos($xmlParcial, '<emit>') !== false ? 'ok' : 'faltando'),
    'produtos: ' . (substr_count($xmlParcial, '<det>') > 0 ? 'ok' : 'faltando'),
    'total: ' . (strpos($xmlParcial, '<ICMSTot>') !== false ? 'ok' : 'faltando'),
    'pag: ' . (strpos($xmlParcial, '<pag>') !== false ? 'ok' : 'faltando'),
]));

if ($nfe->dom->documentElement === null) {
    throw new Exception("Erro: XML da NFC-e não foi construído corretamente. Verifique os dados de entrada.");
}


      $xml = $nfe->getXML();
      file_put_contents(__DIR__ . '/nfe-xml.txt', $xml);
    } catch (Exception $e) {
      file_put_contents(__DIR__ . '/debug-final-xml.log', $e->getMessage() . "\n" . $e->getTraceAsString());
      throw new Exception("Erro ao gerar XML final: " . $e->getMessage());
    }

*/



<?php
/**
 * gerar-xml-NFC-ajustado.php
 * ----------------------------------------------
 * Gera XML de NFC-e (modelo 65) usando NFePHP\NFe\Make
 * com tratamento automático de ICMS x ICMSSN conforme CRT.
 *
 * \nFluxo resumido:\n
 *  1. Recebe JSON via POST (Content-Type: application/json).
 *  2. Monta objetos stdClass para cada grupo: ide, emit, dest(opc), produtos, totais, pagamentos.
 *  3. Detecta Regime Tributário através de $emit->CRT (1 ou 2 = Simples; 3 = Regime Normal).
 *  4. Para cada produto: chama tagprod(); depois, se Simples => tagICMSSN(); senão => tagICMS().
 *     PIS/COFINS idem (usa tagPIS(), tagCOFINS()).
 *  5. Monta totais, pagamentos, gera XML, assina e retorna JSON.
 *
 * Observações:
 *  - Este script supõe que você já tem o arquivo de configuração do Tools (config.json) e o certificado PFX.
 *  - Ajuste caminhos conforme seu ambiente.
 *  - Campos mínimos para NFC-e podem variar por UF; revise layout vigente.
 */

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once __DIR__ . '/vendor/autoload.php';

use NFePHP\NFe\Make;
use NFePHP\NFe\Tools;
use NFePHP\NFe\Complements;
use NFePHP\Common\Certificate;
use NFePHP\Common\Files\FilesFolders;

header('Content-Type: application/json; charset=utf-8');

// -----------------------------------------------------------------------------
// Helpers
// -----------------------------------------------------------------------------
/** Converte array recursivamente em stdClass. */

function arr2obj($array) {
    return json_decode(json_encode($array));
}

    
function safeConvert($input, $context = '') {
    if (is_array($input)) {
        return json_decode(json_encode($input));
    }
    if (is_string($input)) {
        $obj = json_decode($input);
        if (json_last_error() === JSON_ERROR_NONE) return $obj;
        throw new Exception("Erro ao decodificar JSON em $context");
    }
    if (is_object($input)) {
        return $input;
    }
    throw new Exception("Formato inválido em $context");
}

/** Pega valor seguro */
function v($src,$key,$def=null){return (is_array($src)&&array_key_exists($key,$src))?$src[$key]:((is_object($src)&&isset($src->{$key}))?$src->{$key}:$def);}    

/** Normaliza decimal em string com ponto */
function num($v,$dec=2){if($v===null||$v==='')return number_format(0,$dec,'.','');return number_format((float)$v,$dec,'.','');}

// -----------------------------------------------------------------------------
// Entrada JSON
// -----------------------------------------------------------------------------
try {
    $body = file_get_contents('php://input');

    if ($body === false) { throw new Exception('Falha ao ler entrada (php://input).'); }

    $input = json_decode($body, true);

    //Log
    //file_put_contents(__DIR__ . '/debug-entrada.log', print_r($body, true));
    //

    if (!is_array($input)) { throw new Exception('JSON inválido recebido no POST.'); }

    // Aceita tanto formato {json:{...}} quanto {...} direto
    $json = isset($input['json']) && is_array($input['json']) ? $input['json'] : $input;

    // ------------------------------------------------------------------
    // Certificado
    // ------------------------------------------------------------------
    $certFile = __DIR__ . '/certs/' . ($json['nm_certificado'] ?? 'certificado.pfx');

    if (!file_exists($certFile)) {
        throw new Exception("Certificado não encontrado: {$certFile}");
    }

    $senhaCert = $json['cd_senha_certificado'] ?? '';
    $certContent = file_get_contents($certFile);
    $certificate = Certificate::readPfx($certContent, $senhaCert);

    // ------------------------------------------------------------------
    // Config Tools (ajuste conforme seu ambiente)
    // ------------------------------------------------------------------

    $cnpjBruto = trim(
    $json['emit']['CNPJ'] ??
    $json['cd_cnpj'] ??
    $json['cnpj'] ??
    ''
    );

    //file_put_contents('debug-cnpj.log', print_r($json, true));

    $configJson = [
        'atualizacao' => date('Y-m-d H:i:s'),
        'tpAmb'       => (int)($json['tpAmb'] ?? 2), // 1=Prod, 2=Homolog
        'razaosocial' => $json['emit']['xNome'] ?? 'Empresa Teste',
        'siglaUF'     => $json['emit']['UF'] ?? 'SP',
        'cnpj'        => $cnpjBruto, 
        'schemes'     => 'PL_009_V4',
        'versao'      => '4.00',
        'tokenIBPT'   => '',
        'CSC'         => $json['emit']['CSC'] ?? '',
        'CSCid'       => $json['emit']['CSCid'] ?? ''
    ];

    //
    $config = json_encode($configJson);
    //
    $tools = new Tools($config, $certificate);
    //

    function registrarErroTag($tag, $linha) {
       file_put_contents(__DIR__ . '/debug-tag.log', "Erro: {$tag} em linha {$linha}
    ", FILE_APPEND);
    }



    
    // ------------------------------------------------------------------
    // Instancia NFe Make
    // ------------------------------------------------------------------
    
$nfe = new Make();

    $infNFe    = safeConvert($json['infNFe'] ?? [], 'infNFe');

    var_dump($infNFe); // <-- Adicione aqui

    $ide       = safeConvert($json['ide'] ?? [], 'ide');
    $emit      = safeConvert($json['emit'] ?? [], 'emit');
    $enderEmit = isset($emit->enderEmit) ? safeConvert($emit->enderEmit, 'enderEmit') : null;
    $produtos  = $json['produtos'] ?? [];
    $total     = safeConvert($json['total'] ?? [], 'total');
    $transp    = safeConvert($json['transp'] ?? [], 'transp');
    $pag       = safeConvert($json['pag'] ?? [], 'pag');

    if (!isset($infNFe->versao) || !isset($infNFe->Id)) {
        throw new Exception("infNFe deve conter os campos 'versao' e 'Id'");
    }

    $nfe->taginfNFe($infNFe);
    $nfe->tagide($ide);
    $nfe->tagemit($emit);
    if ($enderEmit) $nfe->tagenderEmit($enderEmit);

    $CRT = (int)($emit->CRT ?? 3);

    foreach ($produtos as $i => $prodRaw) {
        $prod = safeConvert($prodRaw, "produto{$i}");
        $nfe->tagprod($prod);

        $imp = new stdClass();
        $imp->item = $prod->item ?? $prod->nItem ?? ($i + 1);
        if (isset($prod->vTotTrib)) $imp->vTotTrib = (float)$prod->vTotTrib;
        $nfe->tagimposto($imp);

        if (isset($prod->ICMS)) {
            $icms = safeConvert($prod->ICMS, "ICMS{$i}");
            $icms->item = $imp->item;
            $CRT <= 2 ? $nfe->tagICMSSN($icms) : $nfe->tagICMS($icms);
        }

        if (isset($prod->PIS)) {
            $pis = safeConvert($prod->PIS, "PIS{$i}");
            $pis->item = $imp->item;
            $nfe->tagPIS($pis);
        }

        if (isset($prod->COFINS)) {
            $cofins = safeConvert($prod->COFINS, "COFINS{$i}");
            $cofins->item = $imp->item;
            $nfe->tagCOFINS($cofins);
        }
    }

    $nfe->tagICMSTot($total);

    if (!empty((array)$transp)) {
        $nfe->tagtransp($transp);
    }

    if (!empty((array)$pag)) {
        $nfe->tagpag($pag);
        if (isset($pag->detPag)) {
            foreach ((array)$pag->detPag as $p) {
                $det = is_array($p) ? arr2obj($p) : $p;
                $nfe->tagdetPag($det);
            }
        }
    }

    if ($nfe->dom->documentElement === null) {
        throw new Exception("Erro: XML não foi montado corretamente. Verifique se todos os campos obrigatórios foram preenchidos corretamente.");
    }

    $xml = $nfe->montaNFe();
    $xml = $nfe->getXML();
    file_put_contents(__DIR__ . '/nfce-gerada.xml', $xml);
    echo $xml;

    // Assina
    $xmlAssinado = $tools->signNFe($xml);

    //
    $xmlComSuplemento = Complements::addQrcode($xmlAssinado, $configJson['CSC'], $configJson['CSCid']);
    //
    //$lote = $tools->sefazEnviaLote([$xmlComSuplemento]);
    //

    // Salva debug opcional
    file_put_contents(__DIR__ . '/log_php_debug.xml', $xmlAssinado);

    // Retorno JSON
    echo json_encode([
        'status' => 'ok',
        'xml'    => $xmlComSuplemento,
        'retornoSefaz' => $lote
    ], JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_PRETTY_PRINT);
    exit;

} catch (Exception $e) {
    file_put_contents(__DIR__ . '/log_erro_execucao.txt', $e->getMessage() . "\n" . $e->getTraceAsString());
    http_response_code(500);
    echo json_encode([
        'erro'      => 'Erro ao gerar XML da NFC-e',
        'mensagem'  => $e->getMessage()
    ], JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES|JSON_PRETTY_PRINT);
    exit;
}