import 'package:arbomonitor/modules/armadilhaOvo/repositories.dart';
import 'package:arbomonitor/modules/armadilhaOvo/usecases.dart';
import 'package:arbomonitor/modules/common/repositories.dart';
import 'package:arbomonitor/modules/common/usecases.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'package:arbomonitor/modules/auth/repositories.dart';
import 'package:arbomonitor/modules/auth/usecases.dart' as auth_use_case;
import 'package:arbomonitor/modules/aplicacao/repositories.dart';
import 'package:arbomonitor/modules/aplicacao/usecases.dart';
import 'package:arbomonitor/modules/menu/repositories.dart';
import 'package:arbomonitor/modules/menu/usecases.dart';
import 'package:arbomonitor/modules/vistoriaResidencial/repositories.dart';
import 'package:arbomonitor/modules/vistoriaResidencial/usecases.dart';

Future<Box<dynamic>> dB = getHiveDB();

Future<Box<dynamic>> getHiveDB() async {
  final directory = await getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  return Hive.openBox('projetoArboMonitor');
}

final authRepository = AuthRepository(dB);
final aplicacaoRepository = AplicacaoRepository(dB);
final menuRepository = MenuRepository(dB);
final commonRepository = CommonRepository();
final vistoriaRepository = VistoriaRepository();
final armadilhaOvoRepository = ArmadilhaOvoRepository();

final getTokenUseCase = auth_use_case.GetTokenUseCase(authRepository);
final setTokenUseCase = auth_use_case.SetTokenUseCase(authRepository);
final clearTokenUseCase = auth_use_case.ClearTokenUseCase(authRepository);
final verifyCredentialsUseCase =
    auth_use_case.VerifyCredentialsUseCase(authRepository);
final logOutUseCase = auth_use_case.LogOutUseCase(authRepository);

final fetchUserUseCase = FetchUserUseCase(menuRepository);

final fetchAtividadesAplicacaoUseCase =
    FetchAtividadesAplicacaoUseCase(aplicacaoRepository);
final getAtividadesAplicacaoListUseCase =
    GetAtividadesAplicacaoListUseCase(aplicacaoRepository);
final setAtividadesAplicacaoListUseCase =
    SetAtividadesAplicacaoListUseCase(aplicacaoRepository);

final getTrabalhoAplicacaoAndamentoUseCase =
    GetTrabalhoAplicacaoAndamentoUseCase(aplicacaoRepository);
final setTrabalhoAplicacaoAndamentoUseCase =
    SetTrabalhoAplicacaoAndamentoUseCase(aplicacaoRepository);
final sendTrabalhoAplicacaoUseCase =
    SendTrabalhoAplicacaoUseCase(aplicacaoRepository);
final clearTrabalhoAplicacaoAndamentoUseCase =
    ClearTrabalhoAplicacaoAndamentoUseCase(aplicacaoRepository);
final concluirTrabalhoAplicacaoAndamentoUseCase =
    ConcluirTrabalhoAplicacaoAndamentoUseCase(aplicacaoRepository);
final verifyTrabalhoAplicacaoAndamentoUseCase =
    VerifyTrabalhoAplicacaoAndamentoUseCase(aplicacaoRepository);

final getTrabalhosAplicacaoPendentesUseCase =
    GetTrabalhosAplicacaoPendentesUseCase(aplicacaoRepository);
final getTrabalhoAplicacaoPendenteUseCase =
    GetTrabalhoAplicacaoPendenteUseCase(aplicacaoRepository);
final setTrabalhoAplicacaoPendenteUseCase =
    SetTrabalhoAplicacaoPendenteUseCase(aplicacaoRepository);
final removeTrabalhoAplicacaoPendenteUseCase =
    RemoveTrabalhoAplicacaoPendenteUseCase(aplicacaoRepository);

final clearTrabalhosAplicacaoPendentesUseCase =
    ClearTrabalhosAplicacaoPendentesUseCase(aplicacaoRepository);
final verifyTrabalhosAplicacaoPendentesUseCase =
    VerifyTrabalhosAplicacaoPendentesUseCase(aplicacaoRepository);

final getTrabalhosAplicacaoConcluidosUseCase =
    GetTrabalhosAplicacaoConcluidosUseCase(aplicacaoRepository);

final getTrabalhoAplicacaoConcluidoUseCase =
    GetTrabalhoAplicacaoConcluidoUseCase(aplicacaoRepository);
final setTrabalhoAplicacaoConcluidoUseCase =
    SetTrabalhoAplicacaoConcluidoUseCase(aplicacaoRepository);
final removeTrabalhoAplicacaoConcluidoUseCase =
    RemoveTrabalhoAplicacaoConcluidoUseCase(aplicacaoRepository);
final clearTrabalhosAplicacaoConcluidosUseCase =
    ClearTrabalhosAplicacaoConcluidosUseCase(aplicacaoRepository);
final verifyTrabalhosAplicacaoConcluidosUseCase =
    VerifyTrabalhosAplicacaoConcluidosUseCase(aplicacaoRepository);

final fetchMapMatchingUseCase = FetchMapMatchingUseCase(aplicacaoRepository);

final getEstacaoUseCase = GetEstacaoUseCase(aplicacaoRepository);
final getDadoEstacaoUseCase = GetDadoEstacaoUseCase(aplicacaoRepository);

final fetchTipoPropriedadeUseCase =
    FetchTipoPropriedadeUseCase(commonRepository);
final fetchQuadranteMapDistanciaUseCase =
    FetchQuadranteMapDistanciaUseCase(commonRepository);
final fetchQuadranteUseCase = FetchQuadranteUseCase(commonRepository);
final fetchMapboxGeocodingUseCase =
    FetchMapboxGeocodingUseCase(commonRepository);
final fetchEnderecoUseCase = FetchEnderecoUseCase(commonRepository);
final sendImageUseCase = SendImageUseCase(commonRepository);

final fetchVistoriasUseCase = FetchVistoriasUseCase(vistoriaRepository);
final fetchVistoriaSituacaoUseCase =
    FetchVistoriaSituacaoUseCase(vistoriaRepository);
final fetchVistoriaSituacaoFechadoUseCase =
    FetchVistoriaSituacaoFechadoUseCase(vistoriaRepository);
final fetchTipoFocoUseCase = FetchTipoFocoUseCase(vistoriaRepository);
final sendVistoriaUseCase = SendVistoriaUseCase(vistoriaRepository);

final fetchArmadilhasOvoUseCase =
    FetchArmadilhasOvoUseCase(armadilhaOvoRepository);
final sendArmadilhaOvoUseCase = SendArmadilhaOvoUseCase(armadilhaOvoRepository);
final fetchOcorrenciaVistoriaArmadilhaUseCase =
    FetchOcorrenciaVistoriaArmadilhaUseCase(armadilhaOvoRepository);
final sendVistoriaArmadilhaUseCase =
    SendVistoriaArmadilhaUseCase(armadilhaOvoRepository);
final removeArmadilhaOvoUseCase =
    RemoveArmadilhaOvoUseCase(armadilhaOvoRepository);
