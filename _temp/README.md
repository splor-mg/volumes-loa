# Scripts para Correções Amplas no Projeto Volumes-LOA

Este diretório contém scripts para corrigir problemas que afetam todos os 7 volumes do projeto.

## Problema Identificado

O erro principal é de **case sensitivity**:
- O arquivo existe como `utils/funcoes.R` (R maiúsculo)
- Os scripts tentam carregar `utils/funcoes.r` (r minúsculo)
- No Linux/WSL, o sistema de arquivos é case-sensitive
- **Este problema afeta TODOS os 7 volumes**, não apenas o volume 7

## Scripts Disponíveis

### 1. `main_fixes.sh` ⭐ **SCRIPT PRINCIPAL**
**O que faz:** Orquestra todo o processo de correção
- Executa verificação do estado atual
- Aplica correções de case sensitivity
- Testa todos os 7 volumes
- Mostra relatório final

**Como usar:**
```bash
chmod +x _temp/main_fixes.sh
./_temp/main_fixes.sh
```

### 2. `check_current_state.sh`
**O que faz:** Verifica o estado atual do projeto
- Mostra estrutura de todos os 7 volumes
- Conta quantos arquivos têm problemas
- Lista dependências principais
- Identifica arquivos que precisam ser corrigidos

**Como usar:**
```bash
chmod +x _temp/check_current_state.sh
./_temp/check_current_state.sh
```

### 3. `fix_case_sensitivity.sh`
**O que faz:** Corrige o problema de case sensitivity
- Substitui `funcoes.r` por `funcoes.R` em TODOS os arquivos .R
- Mostra quantos arquivos foram corrigidos
- Verifica se a correção foi bem-sucedida

**Como usar:**
```bash
chmod +x _temp/fix_case_sensitivity.sh
./_temp/fix_case_sensitivity.sh
```

### 4. `test_all_volumes.sh`
**O que faz:** Testa todos os 7 volumes após correções
- Verifica estrutura de cada volume
- Conta scripts .R em cada volume
- Identifica problemas restantes
- Gera relatório de status

**Como usar:**
```bash
chmod +x _temp/test_all_volumes.sh
./_temp/test_all_volumes.sh
```

### 5. `fix_filename_according_to_makefile.sh`
**O que faz:** Renomeia arquivos .Rnw para o nome esperado pelo Makefile
- Detecta arquivos .Rnw com nomes incorretos (ex.: `T7_Quadro_Geral_da_Receita.Rnw`)
- Oferece renomear para o nome esperado pelo Makefile (ex.: `T7_QUADRO_GERAL_DA_RECEITA.Rnw`)
- Mostra o comando `mv` que será executado e pede confirmação

**Como usar:**
```bash
chmod +x _temp/fix_filename_according_to_makefile.sh
./_temp/fix_filename_according_to_makefile.sh
```

### 6. `normalize_covers.sh`
**O que faz:** Padroniza os nomes de capa dos volumes para `capaLOA.pdf`
- Busca variações case-insensitive em `volume*/Rnw/` (ex.: `CapaLOA.pdf`, `CAPALOA.pdf`)
- Mostra o comando `mv` que será executado e pede confirmação
- Evita sobrescrever caso `capaLOA.pdf` já exista

**Como usar:**
```bash
chmod +x _temp/normalize_covers.sh
./_temp/normalize_covers.sh
```

### 7. `fix_R_script_filenames_according_to_makefile.sh`
**O que faz:** Renomeia scripts `.R` para o nome esperado pelo Makefile
- Lê padrões das regras do Makefile para `volume1/data/*.txt: volume1/R/*.R`
- Busca variações case-insensitive e propõe renomeação com confirmação

**Como usar:**
```bash
chmod +x _temp/fix_R_script_filenames_according_to_makefile.sh
./_temp/fix_R_script_filenames_according_to_makefile.sh
```

### 8. `fix_checks_filenames.sh`
**O que faz:** Alinha os nomes dos arquivos de referência (golden `.tex`) com os nomes esperados pelos testes
- Lê nomes esperados das chamadas Report('NAME', 'volume') em `checks/`
- Procura variações case-insensitive em `checks/assets/tex` e propõe renomear com confirmação

**Como usar:**
```bash
chmod +x _temp/fix_checks_filenames.sh
./_temp/fix_checks_filenames.sh
```

## Ordem Recomendada de Execução

**Opção 1 - Automática (Recomendada):**
```bash
./_temp/main_fixes.sh
```

**Opção 2 - Manual:**
1. `check_current_state.sh` - verificar estado atual
2. `fix_case_sensitivity.sh` - aplicar correções de funcoes.r
3. `fix_filename_according_to_makefile.sh` - corrigir nomes de arquivos .Rnw
4. `normalize_covers.sh` - padronizar capas `capaLOA.pdf`
5. `fix_R_script_filenames_according_to_makefile.sh` - corrigir nomes de scripts .R
6. `fix_checks_filenames.sh` - alinhar nomes dos golden `.tex`
7. `test_all_volumes.sh` - testar todos os volumes

## Logs

- O script de teste salva o log em `_temp/volume7_test_output.log`
- Todos os scripts mostram informações detalhadas no terminal

## Segurança

- Os scripts fazem backup automático antes de modificar arquivos
- Apenas substituem o texto exato `funcoes.r` por `funcoes.R`
- Não modificam outras partes do código
