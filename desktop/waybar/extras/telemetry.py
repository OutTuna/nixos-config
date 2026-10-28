import ctypes as c
import json
from pathlib import Path
import sys


def cpu_temperature():
    for hwmon in Path('/sys/class/hwmon').glob('hwmon*'):
        try:
            name = (hwmon / 'name').read_text().strip()
            if name not in ('k10temp', 'coretemp', 'zenpower'):
                continue
            temperatures = list(hwmon.glob('temp*_input'))
            preferred = []
            for sensor in temperatures:
                label = sensor.with_name(sensor.name.replace('_input', '_label'))
                if label.exists() and label.read_text().strip() in ('Tctl', 'Package id 0'):
                    preferred.append(sensor)
            values = [float(p.read_text()) / 1000 for p in (preferred or temperatures)]
            if values:
                value = round(max(values))
                return {'text': f'{value}°C', 'tooltip': f'CPU: {value} °C',
                        'class': 'critical' if value >= 90 else 'normal'}
        except (OSError, ValueError):
            continue
    raise RuntimeError('CPU temperature sensor unavailable')


def gpu_stats():
    nvml = c.CDLL('/run/opengl-driver/lib/libnvidia-ml.so.1')

    def check(result):
        if result != 0:
            raise RuntimeError(f'NVML error {result}')

    class Utilization(c.Structure):
        _fields_ = [('gpu', c.c_uint), ('memory', c.c_uint)]

    check(nvml.nvmlInit_v2())
    try:
        device = c.c_void_p()
        check(nvml.nvmlDeviceGetHandleByIndex_v2(0, c.byref(device)))
        temperature = c.c_uint()
        usage = Utilization()
        name = c.create_string_buffer(256)
        check(nvml.nvmlDeviceGetName(device, name, len(name)))
        check(nvml.nvmlDeviceGetTemperature(device, 0, c.byref(temperature)))
        check(nvml.nvmlDeviceGetUtilizationRates(device, c.byref(usage)))
        return {'text': f'GPU {usage.gpu}%  {temperature.value}°C',
                'tooltip': f'{name.value.decode()}\nLoad: {usage.gpu}%\nTemperature: {temperature.value} °C',
                'class': 'critical' if temperature.value >= 85 else 'normal'}
    finally:
        nvml.nvmlShutdown()


if __name__ == '__main__':
    try:
        result = cpu_temperature() if sys.argv[1] == 'cpu-temp' else gpu_stats()
    except (OSError, RuntimeError, ValueError) as error:
        result = {'text': 'N/A', 'tooltip': str(error), 'class': 'unavailable'}
    print(json.dumps(result))
