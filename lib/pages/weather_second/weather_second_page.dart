import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extensions/async_value_xx.dart';
import '../../models/cities.dart';
import 'weather_second_provider.dart';

int _selectedCityIndex = 1;

class WeatherSecondPage extends ConsumerWidget {
  const WeatherSecondPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<String>>(
      weatherSecondProvider,
      (previous, next) {
        if (next.hasError && !next.isLoading) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text(next.error.toString()),
              );
            },
          );
        }
      },
    );

    final weather = ref.watch(weatherSecondProvider);

    log(weather.toStr);
    log(weather.props);

    try {
      log('value: ${weather.value}');
    } catch (e) {
      log(e.toString());
    }

    log('valueOrNull: ${weather.valueOrNull}');

    try {
      log('requireValue: ${weather.requireValue}');
    } on StateError {
      log('StateError');
    } catch (e) {
      log(e.toString());
    }

    log('===========');

    return Scaffold(
      appBar: AppBar(
        title: const Text('AsyncValue Details - Second'),
        actions: [
          IconButton(
            onPressed: () {
              _selectedCityIndex = 1;
              ref.invalidate(cityProvider);
              ref.invalidate(weatherSecondProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: weather.when(
          skipError: true,
          skipLoadingOnRefresh: false,
          // skipLoadingOnReload: true,
          data: (temp) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  temp,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 20),
                const GetWeatherButton(),
              ],
            );
          },
          error: (e, st) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  e.toString(),
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                const GetWeatherButton(),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class GetWeatherButton extends ConsumerWidget {
  const GetWeatherButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () {
        final cityIndex = _selectedCityIndex % 4;
        final city = Cities.values[cityIndex];

        _selectedCityIndex++;
        ref.read(cityProvider.notifier).changeCity(city);
      },
      child: const Text('Get Weather'),
    );
  }
}
