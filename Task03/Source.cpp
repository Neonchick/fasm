#include <iostream>
#include <thread>
#include <vector>
#include <fstream>
#include <algorithm>		 
#include <chrono>
#include <random>
#include <mutex>

using namespace std;

ifstream fin;
ofstream fout;
vector<vector<int>> ans;
vector<int> a, b;
vector<thread> threads;
int n, nThread, blockSize;

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
	if (nThread<1)
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
	fin.close();
}

mutex g_lock;

void find(int curThread)
{
	g_lock.lock();
	cout << "Поток " << curThread << " начал работу с индекса " << blockSize * curThread << endl;
	g_lock.unlock();
	for (int i = blockSize * curThread; i < min(n, blockSize * (curThread + 1)); i++)
		if (nod(a[i], b[i]) == 1)
			ans[curThread].push_back(i);
	g_lock.lock();
	cout << "Поток " << curThread << " закончил работу на индексе " << max(blockSize * curThread, min(n, blockSize * (curThread + 1)) - 1) << endl;
	g_lock.unlock();
}

void output(const char *out)
{
	for (auto i : ans)
		for (auto j : i)
			fout << j << ' ';
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

	input(argv[1],argv[2], argv[3]);
	if (n < 1000)
	{
		cout << "Размер массива должен быть >= 1000" << endl;
		return 0;
	}
	if (n % nThread != 0)
		blockSize = n / (nThread - 1);
	else blockSize = n / nThread;
	ans.resize(nThread);
	for (int i = 0; i < min(n, nThread); i++)
		threads.push_back(thread(find, i));
	for (size_t i = 0; i < nThread; i++)
		threads[i].join();
	output(argv[2]);
	return 0;
}