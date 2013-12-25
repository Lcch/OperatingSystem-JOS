#include <inc/thread.h>
#include <inc/lib.h>
#include <inc/x86.h>

int
pthread_create(uint32_t * t_id, void (*f)(void *), void *arg) 
{
	char * t_stack = malloc(PGSIZE);
	struct Trapframe child_tf;

	int childpid = sys_exothread();
	if (childpid < 0) {
		panic("fork sys_exofork error : %e\n", childpid);
	}

	int r;
	uint32_t sta_top, sta[2];
	sta_top = (uint32_t)t_stack + PGSIZE;
	sta[0] = (uint32_t)exit;					// return address
	sta[1] = (uint32_t)arg;					// thread arg
	sta_top -= 2 * sizeof(uint32_t);		
	memcpy((void *)sta_top, (void *)sta, 2 * sizeof(uint32_t));

	child_tf = envs[ENVX(childpid)].env_tf;
  	child_tf.tf_eip = (uint32_t)f;				// set eip
	child_tf.tf_esp = sta_top;						// set esp

	if ((r = sys_env_set_trapframe(childpid, &child_tf)) < 0) {
		cprintf("pthread create: sys_env_set_trapframe: %e\n", r);
		return r;
	}
	if ((r = sys_env_set_status(childpid, ENV_RUNNABLE)) < 0) {
		cprintf("pthread create: set thread status error : %e\n", r);
		return r;
	}

	*t_id = childpid;
	return 0;
}

int 
pthread_join(envid_t id) 
{
	int r;
	while (1) {
		r = sys_join(id);
		if (r != 0) break;
		sys_yield();
	}
	return r;
}

int
pthread_mutex_init(pthread_mutex_t * mutex)
{
	mutex->lock = 0;
	return 0;
}

int
pthread_mutex_lock(pthread_mutex_t * mutex)
{
	while (xchg(&mutex->lock, 1) == 1)
		;
	return 0;
}

int
pthread_mutex_unlock(pthread_mutex_t * mutex)
{
	xchg(&mutex->lock, 0);
	return 0;
}