# Análisis de precios relativos de fuentes alternativas: Expatistan

En este carpeta del repositorio se comparten los datos extraídos y procesados del website [Expatistan](https://www.expatistan.com/cost-of-living) utilizados en el Documento **Los precios de la ropa en Argentina** [^1] junto con el código utilizado para los análisis del documento. Se comparte también el [Libro de códigos](Expatistan_Libro-Codigo.pdf) de las bases de datos. El conjunto de recursos disponibilizados se compone de tres datasets: 

* Base de datos precios relevados por producto y país de Expatistan
* Base de datos de precios relativos por rubro y país
* Tabla de resultados
 
A su vez, se adiciona una carpeta con archivos auxiliares, de forma tal de garantizar la replicabilidad de los procesamientos realizados. 

[^1]: [Schteingart, D.; Schuffer, N.; Ludmer, G.; Sidicaro, N.; Ibarra, I. (2024) Los precios de la ropa en Argentina. Fundar](https://fund.ar/publicacion/los-precios-de-la-ropa-en-la-argentina/)



## Base de datos de precios relevados por producto y país de Expatistan


La base de datos contiene información de precios de 50 productos para un total de 98 países, los cuales son reportados por Expatistan. Este sitio se nutre de información proporcionada voluntariamente por usuarios particulares, lo que significa que no es una fuente de información elaborada por un organismo multilateral ni por institutos de estadísticas oficiales de los países. Sin embargo, representa una fuente de información complementaria y adicional que permite conocer detalles como cuánto cuesta la misma comida en un restaurante de comida rápida o una misma prenda de vestir en 98 países del mundo, incluida Argentina. 

Los datos crudos están disponibilzados en el archivo `precios-textil-raw.zip`, el cual se puede descargar de [aquí](https://github.com/datos-Fundar/precios-textil/releases/tag/data)

## Base de datos de precios relativos por rubro y país

La base de datos de precios relativos por rubro y país es un post-procesamiento de los datos disponibilizados en la base de datos anteriormente mencionada. El procedimiento utilizado permite ver la estructura de precios relativos de distintos bienes y servicios de un país comparado contra el resto de la muestra de países. La metodología utilizada puede ser consultada en el libro códigos. 

- Base de datos: 
  - formato [`.csv`](https://raw.githubusercontent.com/datos-Fundar/precios-textil/main/expatistan/output/precios_relativos_expatistan_20240516.csv)
    

## Tabla de resultados

La tabla de resultados es un post-procesamiento de los datos disponibilizados en la base de datos anteriormente mencionada. El procedimiento realizado permite comparar cuántos otros bienes y servicios de un rubro determinado “compran”, en promedio, la ropa y el calzado en la Argentina y en otros países del mundo. Los resultados arrojados por esta tabla, deben interpretarse del siguiente modo: el valor de 1 en un rubro —por ejemplo, alimentos— significa que en la Argentina una prenda de vestir “compra” la misma cantidad de alimentos que en el resto del mundo; el valor por encima de 1 supone que en la Argentina la indumentaria “compra” más alimentos que en el resto del mundo, mientras que un valor menor a 1 denota que una prenda “compra” menos alimentos que en el resto del mundo. De este modo, si el grueso de los rubros se ubica por encima de 1, ello significa que la ropa “compra” más bienes y servicios que en otras partes del mundo, es decir, que sus precios relativos son altos —y a la inversa si la mayoría de los rubros se ubicaran por debajo de 1—. 


- Base de datos: 
  - formato [`.csv`](https://raw.githubusercontent.com/datos-Fundar/precios-textil/main/expatistan/output/tabla_resultados_expatistan_20240516.csv)


---

<a href="https://fund.ar">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://github.com/datos-Fundar/fundartools/assets/86327859/6ef27bf9-141f-4537-9d78-e16b80196959">
    <source media="(prefers-color-scheme: light)" srcset="https://github.com/datos-Fundar/fundartools/assets/86327859/aa8e7c72-4fad-403a-a8b9-739724b4c533">
    <img src="fund.ar"></img>
  </picture>
</a>

