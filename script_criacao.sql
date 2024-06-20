#Manuel André
#Damiao de Oliveira

drop database sistema_prisional_db;
create database if not exists sistema_prisional_db;
## show databases;
 use sistema_prisional_db;

-- Estrutura da tabela `cela`
--

-- Estrutura da tabela `cela`
CREATE TABLE `cela` (
  `id` int NOT NULL auto_increment,
  `numero` int NOT NULL, -- identificador da cela
  `capacidade` tinyint DEFAULT 8, -- numero maximo de detentos de uma vez a ocuparem o local
  `status_ocupacao` tinyint DEFAULT 0, -- 0 vazio, 1 nao vasio, 2 lotado
  `num_detentos` int DEFAULT 0,
  PRIMARY KEY (`id`)
);

-- Estrutura da tabela `detento`
CREATE TABLE `detento` (
  `id` int NOT NULL auto_increment,
  `nome` varchar(50) NOT NULL,
  `sexo` char	NOT NULL,
  `data_nascimento` date NOT NULL,
  `num_detento` int NOT NULL,
  `data_entrada` date NOT NULL,
  `data_saida` date NOT NULL,
  `cela_id` int NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`cela_id`) REFERENCES `cela`(`id`)
);

-- --------------------------------------------------------

--
-- Estrutura da tabela `funcionario`
--

CREATE TABLE `funcionario` (
  `id` int NOT NULL auto_increment,
  `nome` varchar(50) NOT NULL,
  `cargo` varchar(25) DEFAULT NULL,
  `salario` float DEFAULT NULL,
  `data_contrat` date NOT NULL DEFAULT (current_date()),
   PRIMARY KEY (`id`)
);

-- --------------------------------------------------------

--
-- Estrutura da tabela `resgistro`
--

CREATE TABLE `resgistro` (
  `id` int NOT NULL auto_increment,
  `data` date NOT NULL DEFAULT (current_date()),
  `tipo_moviment` enum('entrada','saida', 'trasferencia') NOT NULL,
  `id_detento` int NOT NULL,
  `id_funcionario` int NOT NULL,
  PRIMARY KEY (`id`)
);

-- --------------------------------------------------------

--
-- Estrutura da tabela `visitante`
--

CREATE TABLE `visitante` (
  `id` int NOT NULL auto_increment,
  `nome` varchar(60) NOT NULL,
  `relacao_detento` varchar(60) NOT NULL,
  `id_detento` int NOT NULL, -- DETENTO A SER VISITADO
   PRIMARY KEY (`id`)
);