import pandas as pd
import os


def get_data(source): 
    f = [f"./output/{x}" for x in os.listdir("./output/") if f'datos_{source}' in x][0]
    data = pd.read_csv(f)
    return data