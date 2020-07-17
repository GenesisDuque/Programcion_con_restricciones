%Autor@ : Genesis Brigitti Duque Escobar
% PRÁCTICA 2 - Fábrica de Aceites
%Enumerado de los meses y los tipos de aceites con los que trabajamos  
enum MESES= {Ene, Feb, Mar, Abr, May, Jun, Jul, Agost, Sept, Octb, Nov, Dic};
enum ACEITES = {VEG1, VEG2,ANV1, ANV2, ANV3};

%Entrada
array [1..5, 1..12] of int: precios; %precios de aceites por su compra 
par int: Valor; %Valor del producto Final 
par int: Maxv;  %Máximo de refinamiento para los vegetales
par int: Maxn;  %Máximo de refinamiento para los no vegetales
par int: Mcap;  %Máxima capacidad del deposito de cada tipo de aceite
par int: Cap;   %Precio por almacenamiento mensual de los aceites
par int: MinD;  %Mínimo de dureza que debe tener el producto final 
par int: MaxD;  %Máximo de durexa que debe tener el producto final
par int: MinB;  %Mínimo de beneficio que se debe tener al final del año
par int: MinT;  %Mínimo de toneladas si usamos algún aceite
par int: kaceites; %Numero de aceites con los cuales trabajar un producto
array[1..5] of int: Cantidad; %Cantidad inicial en el deposito y final del año
array [1..5] of float: durezaAceites;  %durezas de los tipos de aceites

%salida
array[1..5,1..12] of var -99999..99999 :deposito; %Almacenamiento de los Aceites por año
array[1..5,1..12] of var -99999..99999 :refinado; %Cantidad de aceite procesado para el producto final
array[1..5,1..12] of var -99999..99999 :compra;   %Compra para surtir de nuevo los depositos de aceite al inicio de mes

% Restricciones

constraint forall(i in ACEITES, j in MESES)( refinado[i,j] >= 0); 
constraint forall(i in ACEITES, j in MESES)( deposito[i,j] >= 0); 
constraint forall(i in ACEITES, j in MESES)( compra[i,j] >= 0); 

% 1.El refinado no puede ser mas del Maximo de refinamiento dado de los tipos de aceites
constraint forall(i in 1..2)(sum([refinado[i,j]| j in 1..12]) <= Maxv); 
constraint forall(i in 3..5)(sum([refinado[i,j]| j in 1..12]) <= Maxn); 

%2.Cantidad inicial para el mes de Enero 
constraint forall(i in ACEITES)(deposito[i,1] == Cantidad[i] + compra[i,1] -refinado[i,1]); 

%3.Cantidad de los meses Feb hasta Nov.
constraint forall(i in ACEITES, j in 2..11)(deposito[i,j] == deposito[i,j-1] + compra[i,j] - refinado[i,j]); 

%4.Cantidad Final para el mes de Dicimebre 
constraint forall(i in ACEITES)( Cantidad[i] == deposito[i,12]); 

%5.No se puede pasar de la capacidad MCAP lo que se tiene depósitodo para cada mes.
constraint forall( i in ACEITES, j in MESES)(deposito[i,j] <= Mcap);

%6.Cantidad de refinado menor o igual  a lo depositado para Enero
constraint forall(i in ACEITES)(refinado[i,1] <= deposito[i,1]+compra[i,1]);

%7.Cantidad de refinado menor o igual  a lo depositado para Febrero ..Noviembre
constraint forall(i in ACEITES, j  in 2..11)(refinado[i,j] <= deposito[i,j-1] + compra[i,j]);

%8.Cantidad de refinado menor o igual  a lo depositado para Diciembre
constraint forall(i in ACEITES)(refinado[i,12] <= deposito[i,11]+ compra[i,12]);

%9.Intervalos para valores de la compra 
constraint forall( i in ACEITES , j in MESES)(compra[i,j] >= ( Mcap-deposito[i,j]) /\ compra[i,j] <= Mcap);

%10.Suma ponderada del producto conseguido por las durezas tras la mezcla de los aceites, respecto a su mínimo y máximo alcanzable
constraint forall (i in MESES) ((sum([durezaAceites[j] * refinado[j,i]|j in ACEITES])) <= sum([refinado[u,i]|u in ACEITES]) * MaxD);
constraint forall (i in MESES) ((sum([durezaAceites[j] * refinado[j,i]| j in ACEITES])) >= sum([refinado[u,i]|u in ACEITES])* MinD);

%11.El producto no debe hacerse con mas de K aceites. Cada mes los aceites seleccionadas pueden cambiar
constraint sum (i in ACEITES , j in MESES )(bool2int(refinado[i, j]> 0)) <= kaceites;

%12.Si un mes usamos un cierto aceite valor mayor  a 0 , entonces debemos usar como m´ınimo T toneladas.
constraint forall( i in ACEITES, j in MESES)( not(refinado[i,j]>0) \/ (refinado[i,j]>= MinT));

%13. Si utilizamos  aceite VEG1 y VEG2 en un determinado mes, entonces utilizamos ANV3 
constraint forall( i in MESES)( if refinado[1,i]>0 /\refinado[2,i]>0  then  refinado[5,i]>0 endif);

%14.Sumatorio del beneficio del producto final debe ser menor o igual al mininmo alcanzable MinB
constraint sum(i in MESES)(sum([refinado[j,i] * Valor|j in ACEITES]) -sum([deposito[j,i]*Cap|j in ACEITES]) - sum([compra[j,i] * precios[j,i]|j in ACEITES]))>= MinB;

%solve satisfy;
solve maximize sum(i in MESES)(sum([refinado[j,i]*Valor|j in ACEITES]) -sum([ deposito[j,i]*Cap|j in ACEITES]) - sum([compra[j,i] * precios[j,i]|j in ACEITES]));

output ["depósito: \n"];
output [show(deposito[i,j]) ++ " " ++
if j == 12 then "\n" else "" endif |
i in 1..5, j in 1..12];

output ["refinado: \n"];
output [ show(refinado[i,j]) ++ " " ++
if j == 12 then "\n" else "" endif |
i in 1..5, j in 1..12];

output ["compra: \n"];
output [ show(compra[i,j]) ++ " " ++
if j == 12 then "\n" else "" endif |
i in 1..5, j in 1..12];
