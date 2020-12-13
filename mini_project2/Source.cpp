#include <iostream>
#include <thread>
#include <vector>
#include <fstream>
#include <algorithm>		 
#include <chrono>
#include <random>
#include <mutex>
#include <ctime>
#include <set>

using namespace std;

vector<int> states(25), humen(25);
vector<thread> threads;
vector<set<int>> freerooms(3);

mutex g_lock;

bool allWork = true;

void room(int curThread, int cost)
{
	const int WAIT = 0;
	const int STOP = 1;
	int work = true;
	int state = WAIT;
	while (work)
	{
		if (state == WAIT)
			this_thread::yield();
		else
		{
			g_lock.lock();
			cout << "¬ номер " << curThread << " стоимостью " << cost << " заселилс€ гость " << humen[curThread] << " на " << states[curThread] << " милисекунд" << endl;
			g_lock.unlock();

			this_thread::sleep_for(chrono::milliseconds(states[curThread]));

			g_lock.lock();
			cout << "»з номера " << curThread << " стоимостью " << cost << " выселилс€ гость " << humen[curThread] << " после " << states[curThread] << " милисекунд" << endl;
			states[curThread] = WAIT;
			freerooms[cost / 200 - 1].insert(curThread);
			g_lock.unlock();
		}
		g_lock.lock();
		work = allWork || states[curThread] != WAIT;
		state = states[curThread];
		g_lock.unlock();
	}
}

int main()
{
	setlocale(LC_ALL, "");
	srand(time(0));
	const int WAIT = 0;
	const int STOP = 1;

	int n;
	cout << "¬ведите число гостей, которые придут в гостинницу" << endl;
	cin >> n;
	if (n < 0)
	{
		cout << "√остей не может быть отрицательное колличество" <<endl;
		return 0;
	}

	int nThread = 25;
	for (int i = 0; i < 10; i++)
	{
		threads.push_back(thread(room, i, 200));
		freerooms[0].insert(i);
	}
	for (int i = 10; i < 20; i++)
	{
		threads.push_back(thread(room, i, 400));
		freerooms[1].insert(i);
	}
	for (int i = 20; i < 25; i++)
	{
		threads.push_back(thread(room, i, 600));
		freerooms[2].insert(i);
	}

	for (int i = 0; i < n; i++)
	{
		this_thread::sleep_for(chrono::milliseconds(rand() % 500 + 500));

		int gTime = rand() % 4000 + 1000;
		int gMoney = rand() % 1000;
		g_lock.lock();
		cout << "√ость " << i << " зашел в гостинницу, име€ при себе " << gMoney << " монет, и хочет остатьс€ на " << gTime << " милисекунд" << endl;
		g_lock.unlock();
		bool find = false;
		for (int j = 2; j >= 0; j--)
		{
			g_lock.lock();
			if (!find && gMoney / 200 >= j + 1 && !freerooms[j].empty())
			{
				int room = *freerooms[j].begin();
				freerooms[j].erase(room);
				states[room] = gTime;
				humen[room] = i;
				find = true;
			}
			g_lock.unlock();
		}
		if (!find)
			cout << "ƒл€ гост€ " << i << " нет подход€щего номера и он уходит" << endl;
	}

	allWork = false;

	for (size_t i = 0; i < nThread; i++)
		threads[i].join();

	cout << "√остиница обслужила " << n << " гостей и закончила свою работу";
	return 0;
}