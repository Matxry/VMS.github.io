Algoritmo CalificacionesEstudiantes
	Definir totalEst Como Entero;
	Definir not1,not2,promedio Como Real;
	Definir nomEst Como Caracter;
	Definir numEstapr,numEstrep,contEst Como Entero;
	//asigacion de valor inicial para cada variable
	totalEst <- 0;
	not1 <- 0;
	not2 <- 0;
	numEstapr <- 0;
	numEstrep <- 0;
	promedio <- 0;
	contEst <- 0;
	Mostrar "Ingrese el numero de estudiantes"
	Leer totalEst
	Mientras (contEst<totalEst) Hacer
		Mostrar "Ingrese nombre del estudiante"
		Leer nomEst
		Mostrar "Ingrese la nota 1"
		Leer not1
		Mostrar "Ingrese la nota 2"
		Leer not2
		
		promedio <- ((not1+not2)/2)
		//Determinar si el promedio del estudiante es mayor o igual a 28
		Si (promedio>=28) Y (promedio<=40)Entonces
			Mostrar "El estudiante ",nomEst," aprueba"
			numEstapr <- numEstapr + 1
		SiNo
			//Comprobar que la nota del estudiante no supere la nota maxima
			Si promedio>40 Entonces
				Mostrar "los valores ingresados exeden la nota maxima"
			SiNo
				Mostrar "El estudiante ",nomEst," reprueba"
				numEstrep<-numEstrep+1
			Fin Si
		Fin Si
		contEst<-contEst+1
	Fin Mientras
	//Mostrar los resultados finales
	Mostrar "El numero total de estudiantes es: ",totalEst
	Mostrar "El numero de estudiantes aprobados es: ",numEstapr
	Mostrar "El numero de estudiantes reprobados es: ",numEstrep
FinAlgoritmo
