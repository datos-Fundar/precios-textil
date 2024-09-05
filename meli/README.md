# Análisis precios relativos fuentes alternativas: MercadoLibre


En este carpeta del repositorio se comparten los datos extraídos y procesados del website [MercadoLibre](https://mercadolibre.com/) utilizados en el Documento **Los precios de la ropa en Argentina** [^1] junto con el código utilizado para los análisis del documento. Se comparte también el [Libro de códigos](Meli_Libro-Codigo.pdf) de las bases de datos. 

El conjunto de recursos disponibilizados se compone de dos datasets: 

* Base procesada
* Tabla de resultados

A su vez, se adiciona una carpeta con archivos auxiliares, de forma tal de garantizar la replicabilidad de los procesamientos realizados. 

[^1]: [Schteingart, D.; Schuffer, N.; Ludmer, G.; Sidicaro, N.; Ibarra, I. (2024) Los precios de la ropa en Argentina. Fundar](https://fund.ar/publicacion/los-precios-de-la-ropa-en-la-argentina/)

---

## Base de datos precios de ropa relevados por producto y país de MercadoLibre


La base de datos contiene información de precios de 53 productos para un total de 7 países provenientes de publicaciones en MercadoLibre, lo que significa que no es una fuente de información elaborada por un organismo multilateral ni por institutos de estadísticas oficiales de los países. Sin embargo, representa una fuente de información complementaria y adicional que permite conocer detalles como cuánto cuesta un producto similar en distintos países de América Latina.

Dado el tamaño de la base, se optó por alojarla en el request
  

## Tablas de resultados

Tablas generadas con la información volcada en la Base de datos de precios para el documento. Resultan del cruce entre la información de la base y las bases auxiliares, tales como los ponderadores de la Engho o bien del agrupamiento de los resultados en sus categorías (por tipo de prenda, destinatario regular de la prenda, etc.).   

- Resultados: 
  - Tabla 1 [`.csv`](https://raw.githubusercontent.com/datos-Fundar/precios-textil/main/numbeo/datos-procesamiento/precios_relativos_numbeo_20240516.csv)
  - Tabla 2 [`.csv`](https://raw.githubusercontent.com/datos-Fundar/precios-textil/main/numbeo/datos-procesamiento/precios_relativos_numbeo_20240516.csv)
  - Tabla 3 [`.csv`](https://raw.githubusercontent.com/datos-Fundar/precios-textil/main/numbeo/datos-procesamiento/precios_relativos_numbeo_20240516.csv)
  - Grafico 1 [`.csv`](https://raw.githubusercontent.com/datos-Fundar/precios-textil/main/numbeo/datos-procesamiento/precios_relativos_numbeo_20240516.csv)
  - Grafico 2 [`.csv`](https://raw.githubusercontent.com/datos-Fundar/precios-textil/main/numbeo/datos-procesamiento/precios_relativos_numbeo_20240516.csv)
    

---

<a href="https://fund.ar">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/datos-Fundar/fundartools/assets/86327859/6ef27bf9-141f-4537-9d78-e16b80196959">
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/datos-Fundar/fundartools/assets/86327859/aa8e7c72-4fad-403a-a8b9-739724b4c533">
    <img src="fund.ar"></img>
  </picture>
</a>
