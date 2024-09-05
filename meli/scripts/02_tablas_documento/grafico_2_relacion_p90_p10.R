# Grafico 2: dispersion precios percentil 90 a 10 

# Rutas 
instub <- 'precios-textil/meli/input/'
auxiliar <- 'precios-textil/meli/auxiliares'
outstub <- 'precios-textil/meli/output'

#Libreria
library(data.table)
library(tidyverse)
# Cargar datos 
data <- fread(file.path(instub,'base_final.csv'))
# Filtrar por productos de busquedas manuales 
data <- data[tipo_dato == 'Sin filtro de tienda oficial']
data <- data[,producto_buscado_arg := str_to_lower(producto_buscado_arg)]
# Sacar Argentina MEP (es lo mismo que Argentina al ver relacion entre percentiles)
data <- data[pais != 'Argentina MEP']

# Cargar auxiliar con canasta 
aux <- read_csv(file.path(auxiliar,'canasta_engho_total.csv'))
aux <- aux %>% 
  mutate(producto_buscado_arg = str_to_lower(producto_buscado_arg),
         producto_buscado_arg = str_remove(producto_buscado_arg,'\\.$'),
         producto_buscado_arg = if_else(producto_buscado_arg == 'traje hombres','traje hombre',producto_buscado_arg),
         producto_buscado_arg = if_else(producto_buscado_arg == 'buzo bebé','buzo bebe',producto_buscado_arg))

# Calcular ratio por producto
t1 <- data[,.(ratio_90_10 = quantile(precio_dolares, probs=0.9, na.rm=TRUE) / quantile(precio_dolares, probs=0.1, na.rm=TRUE)),
           by=c('producto_buscado_arg','pais','mes')]

# Añadir ponderacion
t1 <- merge(t1,aux,by='producto_buscado_arg',all.x=T)
t1 <- t1[producto_buscado_arg %in% aux$producto_buscado_arg]

# Multiplicar precio por ponderacion 
t1 <- t1[,ratio_90_10 := ratio_90_10 * share_canasta]

# Sumar datos por pais 
t1 <- t1[,.(ratio_90_10 = sum(ratio_90_10)),by=c('pais')]

# Calcular promedio de Latam - Sin Argentina
t2 <- t1 %>% 
  filter(!str_detect(pais,'Argentina')) %>% 
  summarize(ratio_90_10 = mean(ratio_90_10)) %>% 
  mutate(pais = 'Promedio de los 6 países analizados')

t1 <- t1 %>% 
  union_all(t2) 
t1 <- t1 %>% 
  arrange(desc(ratio_90_10))

# Guardar bases 
write_csv(t1,file.path(outstub,'Grafico 2 - relacion percentil 90 y 10.csv'))
