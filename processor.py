import logging
import os
import subprocess
import tempfile
from typing import Dict, Tuple, List, Union

from mtslinker.downloader import download_video_chunk


def get_duration(path: str) -> float:
    result = subprocess.run(
        ['ffprobe', '-v', 'error', '-show_entries', 'format=duration',
         '-of', 'default=noprint_wrappers=1:nokey=1', path],
        capture_output=True, text=True
    )
    if not result or not result.stdout.strip():
        return 0.0
    return float(result.stdout.strip())


def get_audio_codec(path: str) -> str:
    """Возвращает имя аудиокодека (например 'aac') или '' если аудио нет."""
    result = subprocess.run(
        ['ffprobe', '-v', 'error', '-select_streams', 'a:0',
         '-show_entries', 'stream=codec_name',
         '-of', 'default=noprint_wrappers=1:nokey=1', path],
        capture_output=True, text=True
    )
    return (result.stdout or '').strip()


def is_video_file(path: str) -> bool:
    result = subprocess.run(
        ['ffprobe', '-v', 'error', '-select_streams', 'v:0',
         '-show_entries', 'stream=codec_type', '-of', 'default=noprint_wrappers=1:nokey=1', path],
        capture_output=True, text=True
    )
    return result is not None and 'video' in (result.stdout or '')


def write_concat_list(clips: List[dict], list_path: str):
    """Пишем concat-файл в UTF-8 с абсолютными путями."""
    with open(list_path, 'w', encoding='utf-8') as f:
        for clip in clips:
            abs_path = os.path.abspath(clip['path']).replace('\\', '/')
            safe_path = abs_path.replace("'", "'\\''")
            f.write(f"file '{safe_path}'\n")


def concat_clips(clips: List[dict], list_path: str, output_path: str):
    write_concat_list(clips, list_path)
    subprocess.run([
        'ffmpeg', '-y', '-f', 'concat', '-safe', '0',
        '-i', list_path, '-c', 'copy', output_path
    ], check=True)


def process_video_clips(directory: str, json_data: Dict) -> Tuple[float, List[dict], List[dict]]:
    total_duration = float(json_data.get('duration', 0))
    if not total_duration:
        raise ValueError('Duration not found in JSON data.')

    video_clips = []
    audio_clips = []

    for event in json_data.get('eventLogs', []):
        if isinstance(event, dict):
            data = event.get('data', {})
            if isinstance(data, dict) and 'url' in data:
                url = data['url']
                start_time = event.get('relativeTime', 0)
                downloaded_file_path = download_video_chunk(url, directory)

                if is_video_file(downloaded_file_path):
                    video_clips.append({'path': downloaded_file_path, 'start': start_time})
                else:
                    audio_clips.append({'path': downloaded_file_path, 'start': start_time})

    logging.info(f'Total duration: {total_duration}')
    return total_duration, video_clips, audio_clips


def compile_final_video(total_duration: float, video_clips: List[dict], audio_clips: List[dict],
                        output_path: str, max_duration: Union[int, None]):

    if not video_clips:
        logging.error('No video clips found.')
        return

    with tempfile.TemporaryDirectory() as tmp:

        # --- Видео: склеиваем чанки встык ---
        if len(video_clips) == 1:
            merged_video = video_clips[0]['path']
        else:
            merged_video = os.path.join(tmp, 'merged_video.mp4')
            concat_clips(video_clips, os.path.join(tmp, 'video_list.txt'), merged_video)

        # --- Аудио ---
        if audio_clips:
            if len(audio_clips) == 1:
                merged_audio = audio_clips[0]['path']
            else:
                merged_audio = os.path.join(tmp, 'merged_audio.m4a')
                concat_clips(audio_clips, os.path.join(tmp, 'audio_list.txt'), merged_audio)

            # Если аудио уже AAC — копируем без перекодирования (быстро)
            audio_codec = get_audio_codec(merged_audio)
            if audio_codec == 'aac':
                a_codec = 'copy'
                logging.info('Audio is AAC, copying without re-encoding.')
            else:
                a_codec = 'aac'
                logging.info(f'Audio codec is {audio_codec or "unknown"}, re-encoding to AAC.')

            cmd = [
                'ffmpeg', '-y',
                '-i', merged_video,
                '-i', merged_audio,
                '-c:v', 'copy', '-c:a', a_codec,
                '-map', '0:v:0', '-map', '1:a:0',
            ]
            if max_duration:
                cmd += ['-t', str(max_duration)]
            cmd.append(output_path)
            subprocess.run(cmd, check=True)

        else:
            cmd = ['ffmpeg', '-y', '-i', merged_video, '-c', 'copy']
            if max_duration:
                cmd += ['-t', str(max_duration)]
            cmd.append(output_path)
            subprocess.run(cmd, check=True)

    logging.info(f'Done: {output_path}')