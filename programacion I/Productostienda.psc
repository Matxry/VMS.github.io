Algoritmo Productostienda
	Definir nomProd Como Cadena;
	Definir precProd,precTot,subtot Como Real;
	Definir cantProd Como Entero;
	Definir elecClie Como Logico;
	elecClie<-Falso
	precProd<-0.00
	cantProd<-0
	precTot<-0
	//Solicitar los datos del producto deseado
	Repetir
		Mostrar "Ingrese el nombre del producto";
		Leer nomProd
		Mostrar "Ingrese el precio del producto";
		Leer precProd;
		//Comprobar que el precio del producto ingresado se mayor a 0
		Mientras (precProd<=0)
			Mostrar "el valor ingresado es negativo";
			Mostrar "ingrese el valor nuevamente";
			Leer precProd;
		FinMientras;
		Mostrar "ingrese la cantidad de unidades";
		Leer cantProd;
		//Comprobar que la cantidad de productos se mayor a 0
		Mientras (cantProd<=0)
			Mostrar "el valor ingresado es negativo"
			Mostrar "ingrese la cantidad nuevamente"
			Leer cantProd
		FinMientras
		//Calcular el subtotal
		subtot<-precProd*cantProd;
		Mostrar "La suma actual es de : ",subtot;
		//Preguntar al cliente si quiere agregar mas productos
		Mostrar "desea ingresar otro producto";
		Leer elecClie;
	Hasta Que No(elecClie)
	Si subtot>=50 Entonces
		precTot<-(subtot-(subtot*0.1))
	Fin Si
	Imprimir "Esta venta"
	Imprimir "El subtotal de esta venta: ", subtot;
	Imprimir "El total de esta venta es: ", precTot;
	
	
	
FinAlgoritmo
