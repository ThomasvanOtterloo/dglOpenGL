unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils , sdl2 , sdl2_image,
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
    procedure getTextures;

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
  glEnable (GL_TEXTURE_2D);

//  // SDL
 if SDL_Init(SDL_INIT_EVERYTHING) <> 0 then
     OutputDebugString('eh kurwa')

  else
    OutputDebugString('Succes init! yay');
    getTextures;
////  SDL_Quit();
end;

procedure TForm2.Render;
begin
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  gluPerspective(45.0, ClientWidth / ClientHeight, NearClipping, FarClipping);
  glMatrixMode(GL_MODELVIEW);




  glLoadIdentity( ); // Loads the current matrix.
glTranslatef(0,0,-10);   // sets the distance of the world closer to the camera
glPushMatrix(); // adds the matrix state to the stack. (New paper to draw on)
 glBegin(GL_QUADS);
  glTexCoord2f(0,0); glVertex3f(-1,1,0);  //lo
  glTexCoord2f(0,1); glVertex3f(-1,-1,0); //lu
  glTexCoord2f(1,1); glVertex3f(1,-1,0);  //ru
  glTexCoord2f(1,0); glVertex3f(1,1,0);   //ro
glend;
glEnable (GL_TEXTURE_2D);
glPopMatrix(); //  Removes drawing from stack. (Puts paper away)
//https://wiki.delphigl.com/index.php/Tutorial_Lektion_3


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

procedure TForm2.getTextures();
var
  tex : PSDL_Surface;
  TexId: gluInt;
begin




   tex := IMG_Load('C:\Users\t.vanotterloo\Pictures\Felis_silvestris_silvestris_small_gradual_decrease_of_quality.jpg');
  if assigned(@tex) then
  begin
    glGenTextures(1, @TexID);
    glBindTexture(GL_TEXTURE_2D, TexID);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    // Attention! Some image formats expect GL_RGB, GL_BGR instead. This constant is missing in the standard headers
    glTexImage2D(GL_TEXTURE_2D, 0, 3, tex^.w, tex^.H,0, GL_RGB, GL_UNSIGNED_BYTE, tex^.pixels);

    SDL_FreeSurface(tex);
  end;
end;

end.
