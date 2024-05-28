# Potenciostato LabSensE

## Introdução

O Potenciostato LabSensE foi desenvolvido para ser utilizado em pesquisas e aplicações a serem realizadas futuramente no grupo de pesquisa. Nesse repositório está presente o código para uma interface capaz de se comunicar e controlar o potenciostato, assim como o firmware do microcontrolador.

## Aplicativo Potenciostato LabSensE

Neste repositório está presente o código para construção do aplicativo elaborado utilizando Flutter para o planejamento experimental e realização de medidas. O aplicativo suporta atualmente as seguintes funções listadas abaixo.

- Conexão com módulo Arduino via Bluetooth para realização de experimentos
- Planejamento experimental, incluindo cada etapa do experimento, acompanhado de informações complementares como título, descrição e datas
- Realização de medidas, com a possibilidade de visualização dos dados em tempo real graficamente
- Visualização de medidas anteriores, com a possibilidade de exportação dos dados para um arquivo *CSV* ou *txt*.
- Visualização de resultados de medidas anteriores
- Calibração do potenciostato (a ser implementado)

> **Nota>** O aplicativo possui código aberto e pode ser modificado para atender a necessidades específicas de cada usuário ou aplicação.

### Plataformas suportadas

O aplicativo foi desenvolvido utilizando o framework Flutter, o que permite a compilação do aplicativo para as plataformas Android e iOS. Atualmente, o aplicativo está configurado  funcional apenas para dispositivos Android, mas com poucas modificações é possível compilar o aplicativo para dispositivos iOS.

Plataformas como Windows, Linux e MacOS não são suportadas, porém com desenvolvimento adicional é possivel adequar o aplicativo para essas plataformas. Atualmente o que impede o funcionamento do aplicativo nessas plataformas é a comunicação via Bluetooth, pois o pacote utilizado para comunicação com dispositivos Bluetooth é específico para Android e iOS.

### Instalação

O aplicativo pode ser instalado em dispositivos Android através da Play Store. O link para download será disponibilizado futuramente. Também é possível compilar o aplicativo a partir do código fonte presente neste repositório. Irei disponibilizar também um arquivo *apk* para instalação do aplicativo em dispositivos Android na aba *Releases*.

> Para compilar o aplicativo é necessário ter o Flutter instalado na máquina. Para instalar o Flutter, siga as instruções presentes na [documentação oficial](https://flutter.dev/docs/get-started/install).

### Utilização

Para utilizar o aplicativo é necessário que o módulo Arduino esteja conectado ao dispositivo Android via Bluetooth e que o *firmware* presente no módulo esteja carregado. Após a conexão do módulo Arduino com o dispositivo Android, abra o aplicativo e clique no ícone do potenciostato para realizar a conexão.

Após a conexão, você pode criar modelos ou experimentos a serem realizados pelo Potenciostato LabSensE.

1. **Modelos:** são etapas de experimentos que podem ser reutilizadas em diversos experimentos. O aplicativo fornece alguns modelos por padrão, mas você pode criar novos modelos para atender a sua necessidade. Atualmente são suportadas voltametrias cíclicas com janela de potencial, número de ciclos e taxa de varredura configuráveis.

2. **Experimentos:** são experimentos compostos por uma ou mais etapas. Cada experimento poderá ser executado pelo potenciostato e os resultados serão armazenados dentro do aplicativo. Os resultados poderão ser visualizados em tempo real ou posteriormente.

Ao realizar uma medida será necessário informar um título para a execução e uma breve descrição. Após iniciar, a cada etapa os comandos serão carregados ao módulo Arduino e a medida será realizada. Ao final do experimento, os dados serão armazenados no aplicativo e poderão ser exportados para um arquivo *CSV* ou *txt*. Você pode acompanhar as etapas do experimento e visualizar os dados em tempo real.

## Hardware

O hardware do potenciostato é composto por um microcontrolador Arduino e uma placa com o circuito proposto no trabalho entitulado [*Building a Microcontroller Based Potentiostat: A Inexpensive and Versatile Platform for Teaching Electrochemistry and Instrumentation*](https://doi.org/10.1021/acs.jchemed.5b00961), proposto por Gabriel N. Meloni.

Foram necessárias pequenas modificações para nossa aplicação. Os detalhes dessas alterações poderão ser encontrados futuramente em documento que será aqui anexado.

## Informações adicionais

### Contribuições

Contribuições são bem-vindas. Se você deseja contribuir com o projeto, sinta-se à vontade para abrir uma *issue* ou um *pull request*.

### Licença

Este projeto está licenciado sob a licença MIT. Para mais informações, consulte o arquivo [LICENSE](LICENSE).

### Autoria

- Aplicativo: [Vicente Kalinoski Parmigiani](https://linktr.ee/vicenteparmi)
- Firmware: Gabriel N. Meloni, modificado por [Vicente Kalinoski Parmigiani](https://linktr.ee/vicenteparmi)
- Hardware: Gabriel N. Meloni

Projeto desenvolvido no Laboratório de Sensores e Eletroquímicos (LabSensE) da Universidade Federal do Paraná (UFPR), sob orientação dos professores Dr. Marcio Fernando Bergamini e Dr. Luiz Humberto Marcolino Junior.

Agradeço também ao enorme apoio e orientação do Dr. Maurício Papi, que foi fundamental para o desenvolvimento deste projeto.
