#include <iostream>
#include <vector>
#include <fstream>
#include <algorithm>		 
#include <chrono>
#include <random>
#include <omp.h>

using namespace std;

ifstream fin;
ofstream fout;
vector<int> ans;
vector<int> a, b;
int n, nThread;

int nod(int a, int b)
{
	if (b == 0)
		return a;
	return nod(b, a % b);
}

void input(const char *in, const char *out, const char *nThreadStr)
{
	fin.open(in);
	if (!fin.is_open())
	{
		cout << "Неверный входной файл" << endl;
		exit(0);
	}
	fout.open(out);
	if (!fout.is_open())
	{
		cout << "Неверный выходной файл" << endl;
		exit(0);
	}
	nThread = _atoi64(nThreadStr);
	if (nThread < 1)
	{
		cout << "Некоректное колличество потоков" << endl;
		exit(0);
	}
	int an, bn;
	fin >> an;
	int x;
	for (int i = 0; i < an; i++)
	{
		fin >> x;
		a.push_back(x);
	}
	fin >> bn;
	for (int i = 0; i < bn; i++)
	{
		fin >> x;
		b.push_back(x);
	}
	n = min(an, bn);
	if (n < 1000)
	{
		cout << "Размер массива должен быть >= 1000" << endl;
		exit(0);
	}
	fin.close();
}

void output(const char *out)
{
	sort(ans.begin(),ans.end());
	for (auto i : ans)
		fout << i << endl;
	fout.close();
}

int main(int argc, char **argv)
{
	setlocale(LC_ALL, "");
	if (argc < 3)
	{
		cout << "Неверное число аргументов" << endl;
		return 0;
	} 
	
	cout << "Чтение входного файла" << endl;
	input(argv[1], argv[2], argv[3]);
	cout << "Чтение входного файла завершено" << endl;

	unsigned int start_time = clock();
	int count = 0;
	
	// Чтобы потоки не слишком часто переключались.
	int bl = max(500, n / nThread);
	
	#pragma omp parallel num_threads(nThread) firstprivate(count)
	{
		#pragma omp critical (cout)
		{
			cout << "Поток " << omp_get_thread_num() << " начал работу" << endl;
		}
		#pragma omp for schedule(static, bl)
		for (int i = 0; i < n; i++)
		{
			if (nod(a[i], b[i]) == 1)
			{
				#pragma omp critical (push)
				{
					ans.push_back(i);
				}
			}
			count++;
			if (count % (bl / 2) == 0)
			{
				#pragma omp critical (cout)
				{
					cout << "Поток " << omp_get_thread_num() << " уже обработал " << count << " элементов" << endl;
				}
			}
		}
		#pragma omp critical (cout)
		{
			cout << "Поток " << omp_get_thread_num() << " всего обработал " << count << " элементов" << endl;
		}
	}
	unsigned int end_time = clock();
	unsigned int time = end_time - start_time;
	cout << "Обрабодка заняла " << time / 1000.0 << " секунд" << endl;
	output(argv[2]);
	return 0;
}