# Análisis de precios relativos de fuentes alternativas: MercadoLibre


En este carpeta del repositorio se comparten los datos extraídos y procesados del website [MercadoLibre](https://mercadolibre.com/) utilizados en el documento **Los precios de la ropa en Argentina** [^1] junto con el código utilizado para los análisis del documento. Se comparte también el [Libro de códigos](Meli_Libro-Codigo.pdf) de las bases de datos. 

El conjunto de recursos disponibilizados se compone de dos datasets: 

* Base procesada 
* Tabla de resultados [^2]

A su vez, se adiciona una carpeta con archivos auxiliares, de forma tal de garantizar la replicabilidad de los procesamientos realizados. 

[^1]: [Schteingart, D.; Schuffer, N.; Ludmer, G.; Sidicaro, N.; Ibarra, I. (2024) Los precios de la ropa en Argentina. Fundar](https://fund.ar/publicacion/los-precios-de-la-ropa-en-la-argentina/)


[^2]: Las datos compartidos en la tabla de resultados pueden contener, temporalmente, diferencias con respecto a los datos publicados en el documento debido a que los datos se procesaron en distintos momentos.  

---

## Base de datos de precios de ropa relevados por producto y país de MercadoLibre


La base de datos contiene información de precios de 53 productos para un total de 7 países provenientes de publicaciones en MercadoLibre, lo que significa que no es una fuente de información elaborada por un organismo multilateral ni por institutos de estadísticas oficiales de los países. Sin embargo, representa una fuente de información complementaria y adicional que permite conocer detalles como cuánto cuesta un producto similar en distintos países de América Latina.

Los datos crudos están disponibilzados en el archivo `precios-textil-raw.zip`, el cual se puede descargar de [aquí](https://github.com/datos-Fundar/precios-textil/releases/tag/data)
  

## Tablas de resultados

Tablas generadas con la información volcada en la base de datos de precios para el documento. Resultan del cruce entre la información de la base y las bases auxiliares, tales como los ponderadores de la ENGHO o bien del agrupamiento de los resultados en sus categorías (por tipo de prenda, destinatario regular de la prenda, etc.).   

- Resultados: 
  - Tabla 1 [`.csv`](https://github.com/datos-Fundar/precios-textil/blob/main/meli/output/tabla%201%20-%20mediana%20por%20pais.csv)
  - Tabla 2 [`.csv`](https://github.com/datos-Fundar/precios-textil/blob/main/meli/output/tabla%202%20-%20mediana%20vs%20promedio%20latam.csv)
  - Tabla 3 [`.csv`](https://github.com/datos-Fundar/precios-textil/blob/main/meli/output/tabla%203%20-%20mediana%20vs%20promedio%20latam%20por%20categoria.csv)
  - Grafico 1 [`.csv`](https://github.com/datos-Fundar/precios-textil/blob/main/meli/output/Grafico%201%20-%20precio%20canasta%20ropa%20vs%20latam.csv)
  - Grafico 2 [`.csv`](https://github.com/datos-Fundar/precios-textil/blob/main/meli/output/Grafico%202%20-%20relacion%20percentil%2090%20y%2010.csv)
    

---

<a href="https://fund.ar">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/datos-Fundar/fundartools/assets/86327859/6ef27bf9-141f-4537-9d78-e16b80196959">
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/datos-Fundar/fundartools/assets/86327859/aa8e7c72-4fad-403a-a8b9-739724b4c533">
    <img src="fund.ar"></img>
  </picture>
</a>
