# 🗄️ Stored Procedures — MySQL (`loja_tech`)

![MySQL](https://img.shields.io/badge/MySQL-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![MySQL Workbench](https://img.shields.io/badge/MySQL_Workbench-00758F?style=for-the-badge&logo=mysql&logoColor=white)

## 📋 Sobre o projeto

Repositório dedicado à resolução de exercícios práticos de **Stored Procedures no MySQL**, aplicados ao banco de dados relacional de uma loja de tecnologia (`loja_tech`). O projeto explora regras de negócio diretamente no banco, validações de entrada, controle de fluxo e geração de relatórios gerenciais.

---

## 🛠️ Tecnologias e recursos utilizados

- **SGBD & Ferramenta:** MySQL e MySQL Workbench
- **Programação SQL:** Stored Procedures (`DELIMITER`, `BEGIN ... END`)
- **Parâmetros:** `IN` e `OUT`
- **Controle de Fluxo:** Estruturas condicionais (`IF`, `ELSEIF`, `ELSE`)
- **Análise e Agregação:** `COUNT`, `SUM`, `AVG`, `MAX`
- **Manipulação de Dados (DML):** `SELECT`, `INSERT`, `UPDATE`

---

## 🗂️ Estrutura do banco de dados

O banco `loja_tech` é composto pelas seguintes tabelas:

| Tabela | Descrição |
| :--- | :--- |
| `categorias` | Armazena as categorias de produtos da loja |
| `produtos` | Armazena o catálogo de produtos, preços, status e estoque |
| `clientes` | Armazena os dados cadastrais dos clientes |
| `pedidos` | Registra os pedidos realizados e seus respectivos status |
| `itens_pedido` | Detalha os produtos e quantidades pertencentes a cada pedido |
| `log_operacoes` | Histórico de auditoria das operações executadas pelas procedures |

---

## ⚙️ Exercícios desenvolvidos

### 1. `atualizar_preco_categoria`

Atualiza em lote o preço dos produtos ativos de uma categoria específica, aplicando um percentual de aumento ou desconto conforme as regras de negócio.

#### Parâmetros

| Parâmetro | Direção / Tipo | Descrição |
| :--- | :--- | :--- |
| `p_id_categoria` | `IN INT` | Identificador da categoria alvo |
| `p_percentual` | `IN DECIMAL(5,2)` | Percentual de reajuste (`+` aumento / `-` desconto) |
| `p_quantidade_alterada` | `OUT INT` | Retorna o total de produtos atualizados |
| `p_mensagem` | `OUT VARCHAR(255)` | Retorna o status de sucesso ou motivo de erro |

#### Regras de negócio
- Valida previamente se o `p_id_categoria` informado existe no banco.
- Aceita reajustes entre **-50%** (desconto máximo) e **+100%** (aumento máximo).
- Ignora a atualização caso o percentual informado seja igual a `0`.
- Afeta exclusivamente produtos com status ativo na categoria selecionada.
- Grava um registro de auditoria na tabela `log_operacoes` após a execução.

#### Exemplo de uso

```sql
CALL atualizar_preco_categoria(3, 10, @quantidade, @mensagem);

SELECT @quantidade AS produtos_alterados,
       @mensagem   AS resultado;
