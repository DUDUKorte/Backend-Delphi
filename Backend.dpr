program Backend;

{$APPTYPE CONSOLE}

{$R *.res}

// Importa o Horse
uses Horse, Horse.Jhonson, Horse.Commons, System.JSON, System.SysUtils;


// Declaração das variáveis
var
  App: THorse; // Declara variável APP do tipo THorse
  Users: TJSONArray; //Declaração de variável JSON de usuários

begin
  // Inicializa a variável APP
  App := THorse.Create();
  App.Use(Jhonson); // Usar o midleware jhonson para fazer requisição de dados json

  //Inicialização das variáveis
  Users := TJSONArray.Create; // Destruir durante a API para evitar vazamento de memória <<<<<<<<<<<<<<!!!!!!!!

  // Rota para fazer o Ping Pong com verbo HTTP GET
  App.Get('/ping',
    procedure(Req: THorseRequest; Res: THorseResponse) // Variável REQ responsável pela requisição, RES responsável pela resposta
    begin
      Res.Send('<h1>PONG</h1>'); // Callback que é chamado toda vez que essa rota for solicitada
    end);

  // Rota Get para o array de usuários
  App.Get('/users',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc) // Next é utilizado quando trabalhamos com midleware
    begin
      Res.Send<TJSONAncestor>(Users.Clone);
    end);

  // Rota POST para cadastrar um user no JSON
  App.Post('/users',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      User: TJSONObject;

    begin
      User := Req.Body<TJSONObject>.Clone as TJSONObject; // Usar clone só temporariamente, o ideal não seria isso
      Users.AddElement(User);
      Res.Send<TJSONAncestor>(User.Clone).Status(THTTPStatus.Created); // Status code 201 sucesso ao criar

    end);

  // Rota Delete para remover um user do JSON
  App.Delete('/users/:id',
    procedure(Req: THorseRequest; Res: THorseResponse; Next: TProc)
    var
      Id: Integer;

    begin
      Id := Req.Params.Items['id'].ToInteger;
      Users.Remove(Id).Free;
      Res.Send<TJSONAncestor>(Users.Clone).Status(THTTPStatus.NoContent); // Status code 204 sucesso, mas sem anda para devolver
    end);

  // APP ficará escutando a porta 9000 por uma resposta
  App.Listen(9000);
end.
