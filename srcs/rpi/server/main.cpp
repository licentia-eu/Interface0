#include <iostream>
#include <fcntl.h>
#include <sys/stat.h>
#include <mqueue.h>

using namespace std;

int main()
{
    mq_attr oa;
    oa.mq_flags = O_NONBLOCK;
    oa.mq_maxmsg = 10;
    oa.mq_msgsize = 1024 * 1024;
    int h =  mq_open("bau", O_CREAT | O_RDWR, &oa);
    mq_close(h);
    mq_unlink("bau");

    cout << "Hello World!" << endl;
    return 0;
}
