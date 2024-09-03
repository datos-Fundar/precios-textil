# Grafico 1: precio de la canasta familiar de ropa 

# Rutas 
instub <- 'codigo/meli/input/base'
auxiliar <- 'codigo/meli/auxiliar'
outstub <- 'codigo/meli/output'

#Libreria
library(data.table)
library(tidyverse)
# Cargar datos 
data <- fread(file.path(instub,'base_final.csv'))

# Filtrar argentina celeste
data <- data[pais != 'Argentina celeste']

# Calculo de mediana por producto 
t1 <- data[,.(mediana_precio = median(precio_dolares,na.rm=T)),
           by=c('producto_buscado_arg','pais','mes')]
t1 <- t1[,producto_buscado_arg := str_to_lower(producto_buscado_arg)]

# Cargar auxiliar con canasta 
aux <- read_csv(file.path(auxiliar,'canasta_engho_total.csv'))
aux <- aux %>% 
  mutate(producto_buscado_arg = str_to_lower(producto_buscado_arg),
         producto_buscado_arg = str_remove(producto_buscado_arg,'\\.$'),
         producto_buscado_arg = if_else(producto_buscado_arg == 'traje hombres','traje hombre',producto_buscado_arg),
         producto_buscado_arg = if_else(producto_buscado_arg == 'buzo bebé','buzo bebe',producto_buscado_arg))

# Añadir ponderacion
t1 <- t1 %>% 
  left_join(aux,by='producto_buscado_arg')
t1$mes <- NULL

# Filtrar productos de la canasta 
t1 <- t1 %>% 
  filter(producto_buscado_arg %in% aux$producto_buscado_arg)

# Multiplicar por ponderacion de cada pais 
t1 <- t1 %>% 
  mutate(mediana_precio = mediana_precio * share_canasta)

# Sumar productos para obtener precio de la canasta ponderada 
t1 <- t1 %>% 
  group_by(pais) %>% 
  summarize(mediana_precio = sum(mediana_precio))

# Calcular promedio de Latam 
t2 <- t1 %>% 
  filter(!str_detect(pais,'Argentina')) %>% 
  summarize(mediana_precio = mean(mediana_precio)) %>% 
  pull(mediana_precio)

# Calcular relacion frente a promedio Latam
t1 <- t1 %>% 
  mutate(mediana_precio = mediana_precio / t2)
t1 <- t1 %>% 
  mutate(mediana_precio = mediana_precio * 100)

# Guardar bases 
write_csv(t1,file.path(outstub,'Grafico 1 - precio canasta ropa vs latam.csv'))
