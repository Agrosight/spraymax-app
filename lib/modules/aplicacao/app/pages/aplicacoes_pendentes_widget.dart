import 'package:spraymax/modules/common/collor.dart';
import 'package:spraymax/modules/common/components/widgets.dart';
import 'package:spraymax/modules/aplicacao/app/controller/aplicacoes_page_controller.dart';
import 'package:spraymax/modules/aplicacao/app/pages/aplicacao_detail_page.dart';
import 'package:spraymax/modules/common/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
// import 'package:loader_overlay/loader_overlay.dart';
import 'package:spraymax/modules/aplicacao/entities.dart';
import 'package:spraymax/modules/common/consts.dart';

class AplicacoesPendentesWidget extends StatefulWidget {
  const AplicacoesPendentesWidget({super.key});
  @override
  State<AplicacoesPendentesWidget> createState() =>
      _AplicacoesPendentesWidgetState();
}

class _AplicacoesPendentesWidgetState extends State<AplicacoesPendentesWidget> {
  final _searchController = TextEditingController();
  late AplicacoesPageController atividadesPageController;
  @override
  Widget build(BuildContext context) {
    atividadesPageController = Provider.of<AplicacoesPageController>(context);
    atividadesPageController.atividadeAplicacaoFilterString =
        _searchController.text;
    atividadesPageController.filterAtividadesPendentes();
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(
                  height: 10,
                ),
                _searchBar(),
                const SizedBox(
                  height: 10,
                ),
                Observer(
                  builder: (_) => (atividadesPageController
                          .listFilteredAtividadesAplicacaoPendentes.isEmpty)
                      ? _widgetNotHasTrabalho()
                      : Expanded(
                          child: ListView.builder(
                            itemCount: atividadesPageController
                                .listFilteredAtividadesAplicacaoPendentes
                                .length,
                            shrinkWrap: true,
                            itemBuilder: (context, index) => _atividadeItem(
                              atividadesPageController
                                      .listFilteredAtividadesAplicacaoPendentes[
                                  index],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _widgetNotHasTrabalho() {
    String trabalhoText =
        "Nenhuma atividade encontrada. \nPor favor, verifique sua conexão e tente novamente.";

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          const Icon(Icons.sentiment_dissatisfied_outlined, size: 64),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: Text(
                      trabalhoText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  _atividadeItem(AtividadeAplicacao atividade) {
    return GestureDetector(
      onTap: () => {
        _showModalBottomSheet(atividade),
      },
      child: AplicacaoCard(
        atividade: atividade,
        trailing: _widgetHasTrabalho(atividade.id),
      ),
    );
  }
  //   DateTime now = DateTime.now();
  //   String dateString = now.toString().substring(0, 10);
  //   if (atividade.nextApplication.compareTo(dateString) < 0) {
  //     return _atividadeItemAtrasado(atividade);
  //   }
  //   if (atividade.nextApplication.compareTo(dateString) == 0) {
  //     return _atividadeItemExecutar(atividade);
  //   }
  //   return _atividadeItemEspera(atividade);
  // }

  // _atividadeItemAtrasado(AtividadeAplicacao atividade) {
  //   return GestureDetector(
  //     onTap: () => {
  //       _showModalBottomSheet(atividade),
  //     },
  //     child: Card(
  //       child: Container(
  //           padding:
  //               const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
  //           child: Row(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.only(right: 16),
  //                 child: const Icon(Icons.warning, color: Color.fromRGBO(255, 93, 85, 1)),
  //               ),
  //               Expanded(
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     _aplicacaoItemField(atividade),
  //                     _aplicacaoItemOrganizacao(atividade),
  //                     Row(
  //                       children: [
  //                         Text(
  //                             "Ciclo ${atividade.executedCycles}/${atividade.totalCycles} - ",
  //                             style: const TextStyle(
  //                                 fontSize: 12, color: Colors.grey)),
  //                         ClipRRect(
  //                           borderRadius: BorderRadius.circular(20),
  //                           child: Container(
  //                             color: Color.fromRGBO(255, 93, 85, 1),
  //                             child: const Text(
  //                               "     ATRASADA     ",
  //                               style: TextStyle(color: Colors.white),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               _widgetHasTrabalho(atividade.id),
  //             ],
  //           )),
  //     ),
  //   );
  // }

  // _atividadeItemExecutar(AtividadeAplicacao atividade) {
  //   return GestureDetector(
  //     onTap: () => {
  //       _showModalBottomSheet(atividade),
  //     },
  //     child: Card(
  //       child: Container(
  //           padding:
  //               const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
  //           child: Row(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.only(right: 16),
  //                 child: const Icon(Icons.alarm, color: Color.fromRGBO(1, 106, 92, 1)),
  //               ),
  //               Expanded(
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     _aplicacaoItemField(atividade),
  //                     _aplicacaoItemOrganizacao(atividade),
  //                     Row(
  //                       children: [
  //                         Text(
  //                             "Ciclo ${atividade.executedCycles}/${atividade.totalCycles} - ",
  //                             style: const TextStyle(
  //                                 fontSize: 12, color: Colors.grey)),
  //                         ClipRRect(
  //                           borderRadius: BorderRadius.circular(20),
  //                           child: Container(
  //                             color: Color.fromRGBO(1, 106, 92, 1),
  //                             child: const Text(
  //                               "     EXECUTAR HOJE     ",
  //                               style: TextStyle(color: Colors.white),
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               _widgetHasTrabalho(atividade.id),
  //             ],
  //           )),
  //     ),
  //   );
  // }

  // _atividadeItemEspera(AtividadeAplicacao atividade) {
  //   int dias = daysToNow(atividade.nextApplication);
  //   return GestureDetector(
  //     onTap: () => {
  //       _showModalBottomSheet(atividade),
  //     },
  //     child: Card(
  //       child: Container(
  //           padding:
  //               const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
  //           child: Row(
  //             children: [
  //               Container(
  //                 padding: const EdgeInsets.only(right: 16),
  //                 child: Icon(Icons.hourglass_empty, color: primaryColor),
  //               ),
  //               Expanded(
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     _aplicacaoItemField(atividade),
  //                     _aplicacaoItemOrganizacao(atividade),
  //                     Row(
  //                       children: [
  //                         RichText(
  //                           text: TextSpan(
  //                             text:
  //                                 "Ciclo ${atividade.executedCycles}/${atividade.totalCycles} - ",
  //                             style: const TextStyle(
  //                                 fontSize: 12, color: Colors.grey),
  //                             children: <TextSpan>[
  //                               const TextSpan(
  //                                   text: "FALTAM ",
  //                                   style: TextStyle(color: Colors.black)),
  //                               TextSpan(
  //                                   text: "$dias",
  //                                   style: const TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                       color: Colors.black)),
  //                               const TextSpan(
  //                                   text: " DIAS",
  //                                   style: TextStyle(color: Colors.black)),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     )
  //                   ],
  //                 ),
  //               ),
  //               _widgetHasTrabalho(atividade.id),
  //             ],
  //           )),
  //     ),
  //   );
  // }

  // _aplicacaoItemField(AtividadeAplicacao atividadeAplicacao) {
  //   return Row(
  //     children: [
  //       Title(
  //         color: Colors.black,
  //         child: Text(
  //           atividadeAplicacao.activity.field.name,
  //           style: const TextStyle(
  //               fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // _aplicacaoItemOrganizacao(AtividadeAplicacao atividadeAplicacao) {
  //   return Row(
  //     children: [
  //       Text(atividadeAplicacao.activity.field.organizacao.name,
  //           style: const TextStyle(fontSize: 12, color: Colors.grey)),
  //     ],
  //   );
  // }

  _widgetHasTrabalho(int idAtividade) {
    return FutureBuilder(
        future: _atividadeHasTrabalho(idAtividade),
        builder: (BuildContext ctx, AsyncSnapshot result) {
          if (result.data == null) {
            return const SizedBox(width: 56);
          } else {
            if (result.data == 0) {
              return const SizedBox(width: 56);
            }
            if (result.data == 1) {
              return Container(
                padding: const EdgeInsets.only(left: 16),
                child: const Icon(Icons.access_time, color: Colors.grey),
              );
            }
            return Container(
              padding: const EdgeInsets.only(left: 16),
              child: const Icon(Icons.sync_alt, color: Colors.grey),
            );
          }
        });
  }

  Future<int> _atividadeHasTrabalho(int idAtividade) async {
    TrabalhoAplicacao trabalho = await atividadesPageController
        .getTrabalhoAplicacaoPendente(idAtividade);
    if (trabalho.atividadeAplicacao.id != -1) {
      return 1;
    }
    trabalho = await atividadesPageController
        .getTrabalhoAplicacaoConcluido(idAtividade);
    if (trabalho.atividadeAplicacao.id != -1) {
      return 2;
    }
    return 0;
  }

  _searchBar() {
    return Container(
      padding: const EdgeInsets.only(right: 16, left: 16),
      child: TextField(
          onChanged: (value) => {
                atividadesPageController.atividadeAplicacaoFilterString =
                    _searchController.text.trim(),
                atividadesPageController.filterAtividadesPendentes(),
                setState(
                  () => {},
                ),
              },
          controller: _searchController,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.grey,
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
            suffixIcon: _buttonClearSearchResult(),
            hintText: "Buscar atividades",
            isDense: true,
          ),
          autofocus: false),
    );
  }

  _buttonClearSearchResult() {
    return Visibility(
      visible: _searchController.value.text.trim().isNotEmpty,
      child: IconButton(
        onPressed: () => {
          _searchController.clear(),
          setState(() => {}),
        },
        icon: const Icon(Icons.close),
      ),
    );
  }

  _showModalBottomSheet(AtividadeAplicacao atividade) {
    CupertinoActionSheet sheet = CupertinoActionSheet(
      title: Text(
        atividade.activity.field.name,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        CupertinoActionSheetAction(
          child: Text(
            "Informações",
            // style: TextStyle(color: Colors.blue),
            style: TextStyle(color: CustomColor.primaryColor,),
          ),
          onPressed: () {
            Navigator.pop(context, "Info");
          },
        ),
        CupertinoActionSheetAction(
          child: Text(
            "Iniciar",
            style: TextStyle(color: CustomColor.primaryColor,),
          ),
          onPressed: () {
            Navigator.pop(context, "Start");
          },
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(
          "Cancelar",
          style: TextStyle(color: CustomColor.primaryColor, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(
      context: context,
      builder: (context) => sheet,
    ).then(
      (value) => {
        if (value != null)
          {
            _executeAction(atividade, value),
          }
      },
    );
  }

  _executeAction(AtividadeAplicacao atividade, String action) {
    switch (action) {
      case "Info":
        _infoAtividade(atividade);
        break;
      case "Start":
        _iniciarAtividade(atividade);
        break;
      default:
        break;
    }
  }

  _iniciarAtividade(AtividadeAplicacao atividade) async {
    TrabalhoAplicacao trabalho = await atividadesPageController
        .getTrabalhoAplicacaoConcluido(atividade.id);
    if (trabalho.atividadeAplicacao.id != -1) {
      _showDialogHasTrabalhoConcluido();
      return;
    }
    trabalho = await atividadesPageController
        .getTrabalhoAplicacaoPendente(atividade.id);
    if (trabalho.atividadeAplicacao.id != -1) {
      _showDialogLoadTrabalho(trabalho, atividade);
    } else {
      _confirmarNovaAtividade(atividade);
    }

    // atividadesPageController.setAtividadesValue(atividade);
    // atividadesPageController.atividadeAndamentoStatus.value =
    //     AtividadeAndamentoStatus.configurar;
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => Provider(
    //       create: (context) => atividadesPageController,
    //       child: AtividadeDetailPage(
    //         atividade: atividade,
    //       ),
    //     ),
    //   ),
    // );
  }

  _showDialogHasTrabalhoConcluido() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Trabalho existente",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: const Text(
              "A atividade contém um trabalho concluido. \nAguarde o envio para poder iniciar um novo trabalho."),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _okButton(),
              ],
            ),
          ],
        );
      },
    );
  }

  _showDialogLoadTrabalho(
      TrabalhoAplicacao trabalho, AtividadeAplicacao atividade) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Trabalho existente",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: const Text(
              "A atividade contém um trabalho em andamento. \nDeseja continuar a atividade? \n\nCaso crie um novo, os dados do trabalho anterior serão perididos."),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _novoTrabalhoButton(atividade),
                _continuarTrabalhoButton(trabalho),
              ],
            ),
          ],
        );
      },
    );
  }

  _novoTrabalhoButton(AtividadeAplicacao atividade) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: leftButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(context).pop(false);
            await atividadesPageController
                .removeTrabalhoAplicacaoPendente(atividade.id);
            _confirmarNovaAtividade(atividade);
          },
          child: const Text(
            'Novo',
            style: TextStyle(color: Color.fromRGBO(255, 93, 85, 1)),
          ),
        ),
      ),
    );
  }

  _continuarTrabalhoButton(TrabalhoAplicacao trabalho) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: rightButtonDecoration(),
        child: TextButton(
          onPressed: () async {
            Navigator.of(context).pop(false);
            _continuarAtividade(trabalho);
          },
          child: const Text('Continuar', style: TextStyle(color: Color.fromRGBO(1, 106, 92, 1))),
        ),
      ),
    );
  }

  _confirmarNovaAtividade(AtividadeAplicacao atividade) {
    atividadesPageController.setAtividadesValue(atividade);
    atividadesPageController.atividadeAndamentoStatus.value =
        TrabalhoAplicacaoStatus.configurar;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Provider(
          create: (context) => atividadesPageController,
          child: AplicacaoDetailPage(
            atividade: atividade,
          ),
        ),
      ),
    );
  }

  _continuarAtividade(TrabalhoAplicacao trabalho) {
    atividadesPageController.loadTrabalhoAndamento(trabalho);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Provider(
          create: (context) => atividadesPageController,
          child: AplicacaoDetailPage(
            atividade: trabalho.atividadeAplicacao,
            trabalho: trabalho,
          ),
        ),
      ),
    );
  }

  _infoAtividade(AtividadeAplicacao atividade) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            "Detalhes",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          content: _infoDialogContent(atividade),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Row(
              children: [
                _okButton(),
              ],
            ),
          ],
        );
      },
    );
  }

  _infoDialogContent(AtividadeAplicacao atividade) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: <Widget>[
                ListTile(
                  title: const Text("Primeiro ciclo:"),
                  subtitle: Text(dateFormat(atividade.activity.startDate)),
                ),
                ListTile(
                  title: Text("${atividade.totalCycles} ciclos"),
                  subtitle:
                      Text("Intervalo de ${atividade.cycleIntervalDays} dias."),
                ),
                ListTile(
                  title: const Text("Modelo Equipamento:"),
                  subtitle: Text(atividade.equipment.name),
                ),
                ListTile(
                  title: const Text("Produto:"),
                  subtitle: Text(atividade.product.name),
                ),
                ListTile(
                  title: const Text("Taxa de Aplicação:"),
                  subtitle: Text(
                      "${atividade.applicationRate} ${atividade.applicationUnit}"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _okButton() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: oneButtonDecoration(),
        child: TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('OK'),
        ),
      ),
    );
  }
}
