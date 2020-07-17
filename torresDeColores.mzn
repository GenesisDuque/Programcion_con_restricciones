% Adornando la casa de Navidad

%Problema de la mochila
par int : maximoPeso;
enum : Objetos;
array[Objetos] of int pesos;

%occurs <> retorna true iff el encapsulamiento es del mismo tipo 
% deopt <> retorna el valor que se le es asinado o fail en caso no existir

%precondicion del problema
 constraint assert (forall (i int Objetos)(pesos[i]>0)]
 
%seleccion de objetos (con encapsulamiento por  "opt" : hace que pueda ser nada o uno de los cualquiera objetos) , tenemos opt's de x cosas.
  array[1..card(Objetos)] of var opt Objetos : sel; 

%Para usar el opt debemos quitar la carcasa
constraint forall(i in card(Objeto)-1 where occurs(sel[i] /\ sel[i+1]))(pesos[deopt(sel[i])]>= pesos[deopt(sel[i+1])])

% Con absent detectamos si el elemento i es vacio entonces propagamos que todos los demás i+1 tambien lo son
constraint forall(i in 1.. card(Objetos)-1)(absent(sel[i])->absent(sel[i+1]));
