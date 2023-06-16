def extract_lines_with_any_character(input_file, output_file, target_characters):
    with open(input_file, 'r') as file:
        lines = file.readlines()  # テキストファイルの行ごとの内容を読み込む

    extracted_lines = [line for line in lines if any(char in line for char in target_characters)]  # 指定した文字を含む行を抽出

    with open(output_file, 'w') as file:
        file.writelines(extracted_lines)  # 抽出した行を別のファイルに書き出す


# 使用例
input_file_path = 'input.txt'  # 入力ファイルのパス
output_file_path = 'output.txt'  # 出力ファイルのパス
target_characters = ['takeo', 'kawamura']  # 抽出したい文字のリスト

extract_lines_with_any_character(input_file_path, output_file_path, target_characters)
