import pandas as pd


def get_table_result(input_df:pd.DataFrame, pais:str, cat_prop:str = "Ropa y calzado")->pd.DataFrame:
    selected_df = input_df.loc[input_df.pais==pais].copy()
    # n_paises = input_df.pais.nunique()
    cat_prop_str = cat_prop.lower().replace(" ","_")
    precio_x = selected_df.loc[selected_df.categoria_propia==cat_prop,'precio_relativo'].values[0]
    selected_df.loc[:,f'poder_compra_relativo_{cat_prop_str}'] = selected_df.loc[:, "precio_relativo"] / precio_x
    table_result = selected_df.rename(columns={'categoria_propia':'rubro'}).drop(columns=['precio_relativo','pais'])
    
    return table_result



