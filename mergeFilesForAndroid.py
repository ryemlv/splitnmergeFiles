import os
import re

def merge_files_in_current_directory():
    # 현재 작업 디렉토리를 가져옵니다.
    folder = os.getcwd()
    
    # 입력된 폴더 경로 확인
    if not os.path.exists(folder):
        raise FileNotFoundError(f"Folder does not exist: {folder}")

    # 쪼개진 파일들의 리스트를 가져오기
    # 쪼개진 파일들의 인덱스를 파일 이름으로부터 정렬한다 (정렬 기능이 없을 때, 큰 파일을 merge하는 경우 문제였음(ex. 110,11,111) 순서로 합쳐 파일이 깨지는 현상)
    files = [f for f in os.listdir(folder) if f.endswith(".jpg")]
    files.sort(key=lambda x: int(re.findall(r'_([0-9]+)', x)[-1]))

    if not files:
        raise FileNotFoundError("No files found in the folder")

    # 원래 파일의 이름과 확장자를 가져옵니다.
    first_file_name = files[0]
    
    # ".jpg"를 제외한 원래 확장자를 추출합니다.
    original_extension = '.' + first_file_name.split('_')[-1].split('.')[-2]
    
    # 원래 파일의 이름을 가져옵니다.
    original_base_name = '_'.join(first_file_name.split('_')[:-1])
    destination_file = os.path.join(folder, f"{original_base_name}{original_extension}")

    # 출력 파일 스트림을 엽니다.
    try:
        with open(destination_file, 'wb') as output_stream:
            # 쪼개진 파일 합치기
            for file in files:
                file_path = os.path.join(folder, file)
                try:
                    with open(file_path, 'rb') as input_stream:
                        output_stream.write(input_stream.read())
                        print(f"File merged: {file_path}")
                except Exception as e:
                    raise IOError(f"Unable to read or write file: {file_path}") from e
    except Exception as e:
        raise IOError(f"Unable to create output file: {destination_file}") from e

    print("All file merge operations completed.")

# 현재 작업 디렉토리에서 파일을 합칩니다.
merge_files_in_current_directory()
