from googleapiclient.discovery import build # pip3 install google-api-python-client
from google_auth_oauthlib.flow import Flow # pip3 install google-auth-oauthlib
from google.oauth2 import service_account
import qrcode # pip3 install qrcode
import json

enterprise_name = 'enterprises/LC04kagbve'
cloud_project_id = 'dengue-419820'
policy_name = enterprise_name + '/policies/policy1'
credentials = service_account.Credentials.from_service_account_file('.env')
androidmanagement = build('androidmanagement', 'v1', credentials=credentials)

def main():
  print('Autenticado com sucesso.')
  while True:
    opcao = input(
      'Início:\n'
      '1 - Políticas\n'
      '2 - Gerar código QR\n'
      '3 - Dispositivos\n'
      '0 - Sair\n'
      'Digite a opção desejada: ')
    match opcao:
      case "1":
        policies()
      case '2':
        qr_code()
      case '3':
        devices()
      case _:
        exit()

# https://developers.google.com/android/management/reference/rest/v1/enterprises.policies
def policies():
  while True:
    opcao = input(
      '\nPolíticas:\n'
      '1 - Criar/atualizar política\n'
      '2 - Listar\n'
      '3 - Detalhes\n'
      '4 - Deletar\n'
      '0 - Voltar\n'
      'Digite a opção desejada: '
      )
    match opcao:
      case "1":
        create_policy()
        break
      case "2":
        print("Lista de políticas:")
        print(androidmanagement.enterprises().policies().list(parent=enterprise_name).execute())
      case "0":
        return

def create_policy():
  print("Criar/atualizar política")
  file = open('policy.json')
  policy_json = file.read()
  print(androidmanagement.enterprises().policies().patch(
      name=policy_name,
      body=json.loads(policy_json)
  ).execute())
  file.close()

def qr_code():
  print("Gerar código QR")
  enrollment_token = androidmanagement.enterprises().enrollmentTokens().create(
      parent=enterprise_name,
      body={"policyName": policy_name}
  ).execute()

  qr = qrcode.QRCode(
      version=1,
      error_correction=qrcode.constants.ERROR_CORRECT_L,
      box_size=10,
      border=4,
  )
  qr.add_data(enrollment_token['qrCode'])
  qr.make_image(fill_color="black", back_color="white").save("qrcode.png")
  print("Um código QR de provisionamente de dispositivo foi gerado.")

def devices():
  print("\nLista de dispositivos:")
  device_list = androidmanagement.enterprises().devices().list(parent=enterprise_name).execute()
  # print(device_list)
  device_names = []
  if ('devices' in device_list):
    for d in device_list['devices']:
      print(device_list['devices'].index(d)+1,'-',d['name'])
      device_names.append(d['name'])
      if ('nonComplianceDetails' in d):
        print('    nonComplianceDetails:',d['nonComplianceDetails'])
      if ('applicationReports' in d):
        for a in d['applicationReports']:
          if (a['packageName'] == 'br.com.farmgo.arbomonitor'):
            print('    Versão instalada: %s+%d' % (a['versionName'],a['versionCode']))
  else:
    print('Nenhum dispositivo provisionado.')
  while True:
    opcao = input(
      'Dispositivos:\n'
      '1 - Deletar\n'
      '2 - Detalhes\n'
      '0 - Voltar\n'
      'Digite a opção desejada: '
      )
    match opcao:
      case "1":
        print()
        for n in device_names:
          print(device_names.index(n)+1,'-',n)
        opcao = input(
          '0 - Cancelar\n'
          'Digite a opção desejada: '
        )  
        if (opcao == '0'):
          return
        androidmanagement.enterprises().devices().delete(name=device_names[int(opcao)-1]).execute()
        return
      case '2':
        opcao = input('Digite o número do dispositivo: ')
        print(androidmanagement.enterprises().devices().get(name=device_names[int(opcao)-1]).execute())
      case _:
        return

if __name__ == "__main__":
  main()
