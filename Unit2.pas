unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils,
  System.Variants, System.Classes, Vcl.Graphics, DGLOpenGL,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TForm2 = class(TForm)
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure IdleHandler(transmitter: TObject; var Done: Boolean);
    procedure FormResize(Sender: TObject);
    procedure FormDestroy(Sender: TObject);

  private
    StartTime, TimeCount, FrameCount: Cardinal; // FrameCounter
    Frames, DrawTime: Cardinal; // & Timebased Movement
    procedure SetupGL;
    procedure Init;
    procedure Render;
    procedure ErrorHandler;

    { Private declarations }

  public
    DC: HDC;
    RC: HGLRC;
    { Public declarations }
  end;

var
  Form2: TForm2;
  test: Integer = 0;
  NearClipping: Single = 1.0; // Initialize NearClipping to 1.0 globally
  FarClipping: Single = 1000.0; // Initialize FarClipping to 1000.0 globally

implementation

{$R *.dfm}

procedure TForm2.FormCreate(Sender: TObject);
begin
  DC := GetDC(handle);
  if InitOpenGL then
  begin
    RC := CreateRenderingContext(DC, [opDoubleBuffered], 32, 24, 0, 0, 0, 0);
    ActivateRenderingContext(DC, RC);
    SetupGL;
    Application.OnIdle := IdleHandler;
    Init; // where i init the  Application.OnIdle := IdleHandler;
  end
  else
    ShowMessage('OpenGL initialization failed');
end;

procedure TForm2.SetupGL;
begin
  glClearColor(0.3, 0.4, 0.7, 0.0); // Background color: Here is a light blue
  glEnable(GL_DEPTH_TEST); // activate depth test
  glEnable(GL_CULL_FACE); // activate backface culling
end;


procedure TForm2.ErrorHandler;
begin
  if gluErrorString(glGetError) <> 'no error' then
  begin
    Form2.Caption := gluErrorString(glGetError);
  end;

end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  DeactivateRenderingContext;
  DestroyRenderingContext(RC);
  ReleaseDC(handle, DC);
end;

procedure TForm2.FormResize(Sender: TObject);
var
  tmpBool: Boolean;
  NearClipping: Integer;
  FarClipping: Integer;
begin

  glViewport(0, 0, ClientWidth, ClientHeight);
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(45.0, ClientWidth / ClientHeight, NearClipping, FarClipping);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  IdleHandler(nil, tmpBool);
end;

procedure TForm2.Init;
begin
  // global init vars or anything i want to init.
  Application.OnIdle := IdleHandler;
end;

procedure TForm2.Render;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(45.0, ClientWidth / ClientHeight, NearClipping, FarClipping);

  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;

  glTranslatef(0, 0, -5);

  glBegin(GL_QUADS);
  glColor3f(1, 0, 0);
  glVertex3f(0, 0, 0);
  glColor3f(0, 1, 0);
  glVertex3f(1, 0, 0);
  glColor3f(0, 0, 1);
  glVertex3f(1, 1, 0);
  glColor3f(1, 1, 0);
  glVertex3f(0, 1, 0);
  glend;

  //triangle
  glBegin(GL_TRIANGLES);
  glColor3f(1,0,0); glVertex3f(-1,-1, 0);
  glColor3f(1,0,1); glVertex3f( 1,-1, 0);
  glColor3f(1,1,0); glVertex3f( 0, 1, 0);
  glend;


  SwapBuffers(DC);
end;

procedure TForm2.IdleHandler(transmitter: TObject; var Done: Boolean);
begin
  StartTime := GetTickCount;
  Render;

  DrawTime := GetTickCount - StartTime;
  Inc(TimeCount, DrawTime);
  Inc(FrameCount);

  if TimeCount >= 1000 then
  begin
    Frames := FrameCount;
    TimeCount := TimeCount - 1000;
    FrameCount := 0;
    Caption := InttoStr(Frames) + 'FPSjes';
    ErrorHandler;
  end;

  Done := false;
end;

end.
