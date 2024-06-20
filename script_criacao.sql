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
  `sexo` char	NOT NULL default 'M',
  `data_nascimento` date NOT NULL,
  `num_detento` int NOT NULL,
  `data_entrada` date NOT NULL,
  `data_saida` date NOT NULL,
  `cela_id` int,
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
  `cargo` enum('gestao','guarda', 'medico') NOT NULL,
  `salario` float DEFAULT NULL,
  `data_contrat` date NOT NULL DEFAULT (current_date()),
   PRIMARY KEY (`id`)
);

-- --------------------------------------------------------

--
-- Estrutura da tabela `resgistro`
--

CREATE TABLE `registro` (
  `id` int NOT NULL auto_increment,
  `data` date NOT NULL DEFAULT (current_date()),
  `presidio` varchar(20) DEFAULT null,
  `destino` int DEFAULT NULL,
  `tipo_resgistro` enum('entrada','soltura', 'transferencia') NOT NULL,
  `id_detento` int NOT NULL,
  `id_funcionario` int NOT NULL,
  `origem` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`id_funcionario`) REFERENCES `funcionario` (`id`),
  FOREIGN KEY (`id_detento`) REFERENCES `detento` (`id`),
  FOREIGN KEY (`origem`) REFERENCES `cela` (`id`),
  FOREIGN KEY (`destino`) REFERENCES `cela` (`id`)
);

-- criar um trigger que ao criar um registro se o tipo_registro for trasferencia e presidio for null, nao permita que origem e destino seja null

-- --------------------------------------------------------

--
-- Estrutura da tabela `visitante`
--

CREATE TABLE `visitante` (
  `id` int NOT NULL auto_increment,
  `nome` varchar(60) NOT NULL,
  `relacao_detento` varchar(60) NOT NULL,
   `data_entrada` date NOT NULL DEFAULT (current_date()),
  `id_detento` int NOT NULL, -- DETENTO A SER VISITADO
   PRIMARY KEY (`id`),
   FOREIGN KEY (`id_detento`) REFERENCES `detento`(`id`)
);