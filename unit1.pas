unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  EditBtn, DOM, XMLRead, XMLWrite;

type

  { TForm1 }

  TForm1 = class(TForm)
    Button1: TButton;
    FileNameEdit1: TFileNameEdit;
    Memo_Retorno: TMemo;
    procedure Button1Click(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.Button1Click(Sender: TObject);
var
  i,item, i2, i3, iImposto, idet: integer;
  vXMLDoc: TXMLDocument;
  nodeprod, nodeimposto, NodePrim, NodePai, NodeCabecalhoXML, NodeEmitente, NodeDestinatario, NodeSec, NodeTotal: TDOMNode;
begin
  vXMLDoc := TXMLDocument.Create;
  try
    ReadXMLFile(vXMLDoc, filenameedit1.FileName);
    Memo_Retorno.Lines.Clear;
    //Cabeçaho NFe
    NodePrim := vXMLDoc.DocumentElement.FindNode('NFe');
    NodePai := NodePrim.FindNode('infNFe');
    NodeCabecalhoXML := Nodepai.FindNode('ide');

    for i := 0 to NodeCabecalhoXML.ChildNodes.Count -1 do
      Memo_Retorno.Lines.Add( 'CABECALHO-'+ NodeCabecalhoXML.ChildNodes[i].NodeName + ' = ' + Utf8ToAnsi(NodeCabecalhoXML.ChildNodes[i].TextContent) );

    Memo_Retorno.Lines.Add( #13);

    NodeEmitente := NodePai.FindNode('emit');

    for i := 0 to NodeEmitente.ChildNodes.Count -1 do
    begin
      if NodeEmitente.ChildNodes[i].NodeName = 'enderEmit' then
      begin
        for i2 := 0 to NodeEmitente.ChildNodes[i].ChildNodes.Count -1 do
          Memo_Retorno.Lines.Add( 'EMITENTE-ENDERECO-'+ NodeEmitente.ChildNodes[i].ChildNodes[i2].NodeName + ' = ' + Utf8ToAnsi(NodeEmitente.ChildNodes[i].ChildNodes[i2].TextContent) );
      end
      else
        Memo_Retorno.Lines.Add( 'EMITENTE-' + NodeEmitente.ChildNodes[i].NodeName + ' = ' + Utf8ToAnsi(NodeEmitente.ChildNodes[i].TextContent) );
    end;

    Memo_Retorno.Lines.Add( #13);

    NodeDestinatario := NodePai.FindNode('dest');

    for i := 0 to NodeDestinatario.ChildNodes.Count -1 do
    begin
      if NodeDestinatario.ChildNodes[i].NodeName = 'enderDest' then
      begin
        for i2 := 0 to NodeDestinatario.ChildNodes[i].ChildNodes.Count -1 do
          Memo_Retorno.Lines.Add( 'DESTINATARIO-ENDERECO-'+ NodeDestinatario.ChildNodes[i].ChildNodes[i2].NodeName + ' = ' + Utf8ToAnsi(NodeDestinatario.ChildNodes[i].ChildNodes[i2].TextContent) );
      end
      else
        Memo_Retorno.Lines.Add( 'DESTINATARIO-' + NodeDestinatario.ChildNodes[i].NodeName + ' = ' + Utf8ToAnsi(NodeDestinatario.ChildNodes[i].TextContent) );
    end;

    Memo_Retorno.Lines.Add( #13);

    NodeSec := NodePai.FindNode('det');
    item := 0;
    while Assigned(NodeSec) do
    begin
      nodeprod    := NodeSec.FindNode('prod');

      if nodeprod = nil then
        break;

      inc(item);

      Memo_Retorno.Lines.Add( 'ITEM '+ inttostr(item));

      for idet := 0 to nodeprod.ChildNodes.Count -1 do
      begin
        for i := 0 to nodeprod.ChildNodes[idet].ChildNodes.count -1 do
          Memo_Retorno.Lines.Add( 'PRODUTO-' + nodeprod.ChildNodes[idet].NodeName + ' = ' + nodeprod.ChildNodes[idet].ChildNodes[i].TextContent);
      end;

      nodeimposto := NodeSec.FindNode('imposto');

      for iImposto := 0 to nodeimposto.ChildNodes.Count -1 do
      begin
        if nodeimposto.ChildNodes[iImposto].HasChildNodes then
        begin
          for i2 := 0 to nodeimposto.ChildNodes[iImposto].ChildNodes.Count - 1 do
          begin
            if nodeimposto.ChildNodes[iImposto].ChildNodes[i2].HasChildNodes then
            begin
              for i3 := 0 to nodeimposto.ChildNodes[iImposto].ChildNodes[i2].ChildNodes.Count - 1 do
                Memo_Retorno.Lines.Add( uppercase(nodeimposto.ChildNodes[iImposto].ChildNodes[i2].NodeName) + '-' + nodeimposto.ChildNodes[iImposto].ChildNodes[i2].ChildNodes[i3].NodeName + ' = ' + nodeimposto.ChildNodes[iImposto].ChildNodes[i2].ChildNodes[i3].TextContent);
            end
            else
              Memo_Retorno.Lines.Add( uppercase(nodeimposto.ChildNodes[iImposto].NodeName) + '-' + nodeimposto.ChildNodes[iImposto].ChildNodes[i2].NodeName + ' = ' + nodeimposto.ChildNodes[iImposto].ChildNodes[i2].TextContent);
          end;
        end
      end;

      Memo_Retorno.Lines.Add( #13);

      NodeSec := NodeSec.NextSibling;
    end;

    Memo_Retorno.Lines.Add('ITENS = '+ inttostr(item));

    NodeTotal := NodePai.FindNode('total');

    for i := 0 to NodeTotal.ChildNodes.Count -1 do
    begin
      for i2 := 0 to NodeTotal.ChildNodes[i].ChildNodes.Count -1 do
        Memo_Retorno.Lines.Add( 'TOTAL-'+ NodeTotal.ChildNodes[i].ChildNodes[i2].NodeName + ' = ' + Utf8ToAnsi(NodeTotal.ChildNodes[i].ChildNodes[i2].TextContent) );
    end;


  finally
    nodeprod.free;
    nodeimposto.free;
    NodePrim.free;
    NodePai.free;
    NodeCabecalhoXML.free;
    NodeEmitente.free;
    NodeDestinatario.free;
    NodeSec.free;
    NodeTotal.free;

    vXMLDoc.Free;
  end;
end;

end.

