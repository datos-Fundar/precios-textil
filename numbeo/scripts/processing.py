import os
import pandas as pd
import numpy as np


def process_numbeo(input_df:pd.DataFrame)->pd.DataFrame: 

    # Reestructurar el DataFrame para que los países sean las columnas
    df_wide = input_df.pivot(index=['categoria_propia', 'item_names'], columns='country', values='item_prices_usd').reset_index()

    # Separar las categorías y los nombres de productos
    categorias_productos = df_wide[['categoria_propia', 'item_names']]

    # Separar los datos de precios por país
    datos_paises = df_wide.iloc[:, 2:]

    # Obtener la lista de países (columnas)
    paises = datos_paises.columns

    # Crear un DataFrame vacío para almacenar los resultados
    results = pd.DataFrame()
    results['categoria_propia'] = categorias_productos['categoria_propia'].unique()

    # Calcular la media de las medianas para cada país
    for p in paises:
        
        x = datos_paises[~datos_paises[p].isna()]
        lista_precios = x[p]
        datos_no_p = x.drop(columns=[p])
        
        # Dividir cada columna por la columna del país seleccionado
        datos_no_p = datos_no_p.div(lista_precios, axis=0)
        
        # Calcular la mediana de cada fila filtrada, ignorando NaNs
        medianas = np.nanmedian(datos_no_p, axis=1)
        # else:
        #     # Si todas las filas son NaN, generar un array vacío para evitar el warning
        #     medianas = np.array([])

        # Agrupar por categoría y calcular la media de las medianas
        result = pd.DataFrame({
            'categoria_propia': categorias_productos.loc[~datos_paises[p].isna(),'categoria_propia'],
            'medianas': medianas
        })

        result = result.groupby('categoria_propia').agg(media_mediana=('medianas', 'mean')).reset_index()
        
        # Combinar los resultados con el DataFrame principal
        results = pd.merge(results, result, on='categoria_propia', how='left', suffixes=('', f'_{p}'))

    # Renombrar las columnas de resultados para que coincidan con los nombres de los países
    results.columns = ['categoria_propia'] + list(paises)

    # Vuelvo a pivotear. 
    results = results.melt(id_vars='categoria_propia', var_name='pais', value_name='precio_relativo')

    return results

