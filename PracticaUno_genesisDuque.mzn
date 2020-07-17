% Autora :Genesis B Duque E
% Practica 1 - Programación con restricciónes

%Varibales de entrada

enum Turnos= {Mayana, Tarde, Noche, Libre}; %Turnos asignados
par int: D;  % Número de dias
par int: T;  % Número de trabajadores
par int: N;  % Número de trabajadores por turno
par int: X;  % Número de parejas incompatibles
par int: MaxDT;  % Máximo dias de trabajo 
par int: MaxDL;  % Máximo dias libres 
par int: MinDT;  % Mínimo dias libres consecutivos
array[1..T] of bool: supervisores;  %Lista de Supervisores delegados
array[1..X,1..2] of 1..T:incompatibles; % Lista de parejas incompatibles
array[1..T,1..D] of Turnos: noTurno; % Matriz de Turnos no laborables (2-Optimización)


%Varibles de salida

array[1..D,1..T] of var Turnos: sol; %Matriz solución para horarios de trabajadores
var int: sumaoptima;   % Numero de veces que incumplimos la petición (2-Optimizacion)


%Restricciones satisfación 

%Predicados 
constraint assert( T >= 3*N,"Fuera de rango los trabajadores");
constraint assert( MaxDT <= D, "Fuera de rango MaxDT");
constraint assert( MinDT <= MaxDT /\ MinDT < D, "Fuera de rango MinDT");
constraint assert( MaxDL <= D,"Fuera de rango MaxDL");


%Restricciones 

% A. Cada turno tiene n trabajadores
constraint forall(i in 1..D)( N = sum(j in 1..T)(bool2int(sol[i,j]=Tarde)));
constraint forall(i in 1..D)( N = sum(j in 1..T)(bool2int(sol[i,j]=Noche)));
constraint forall(i in 1..D)( N = sum(j in 1..T)(bool2int(sol[i,j]=Mayana)));

% B. Un trabajador puede estar en un solo turno cada dia 
% Implicito en la solucion por el dia*ntrabajadores = D*T  de la matriz

% C. Dado un número MaxDT, garantizar que nadie trabaja MaxDT días consecutivos.
constraint forall(j in 1..T,i in 1..D-MaxDT)(sum(c in i..D)(sol[c,j]!=Libre) <= MaxDT);
                                                   
% D. Dado un número MaxDL, garantizar que nadie tiene MaxDL días libres consecutivos
constraint forall(j in 1..T,i in 1..D-MaxDL)(sum(c in i..i+MaxDL)(sol[c,j]==Libre)<=MaxDL);

% E. Dado un número MinDT, garantizar que todos trabajan como mínimo MinDT en los D días.
constraint forall(i in 1..T)(MinDT <= sum(j in 1..D)(bool2int(sol[j,i]!=Libre)));

% F .Un trabajador no puede hacer el último turno de un día y el primero del día siguiente
constraint forall(i in 1..T)(forall(j in 1..D-1)(sol[j,i] = Noche -> not(sol[j+1,i]=Mayana)));

% G. Dada una serie de parejas de trabajadores incompatibles, dos trabajadores incompatibles no pueden estar en el mismo turno
constraint forall(i in 1..X)(forall( k in 1..D, j,c in 1..T where j < c)(if (incompatibles[i,1]=j /\ incompatibles[i,2]=c) \/ (incompatibles[i,1]=c /\ incompatibles[i,2]=j) then (sol[k,j] !=sol[k,c])endif));

% H. Dados cuáles de los trabajadores son “supervisores”, garantizar que en cada turno hay un supervisor.
constraint forall (i in 1..D) (forall(t in Turnos) (sum (j in 1..T where (occurs(sol[i, j]) /\ deopt(sol[i, j]) == t /\ supervisores[j])) (1) >= 1));

% I. Añadid la posibilidad de que los trabajadores pidan qué turno no quieren 
sumaoptima = sum(i in 1..D , j in 1..T)(bool2int(sol[i,j]==noTurno[j,i]));


solve minimize sumaoptima;
%solve satisfy;

output ["minimo: "++show(sumaoptima)++"\n"];
output [ show(sol[i,j]) ++ " " ++
if j == T then "\n" else "" endif |
i in 1..D, j in 1..T];
