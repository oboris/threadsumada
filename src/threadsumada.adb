with Ada.Text_IO; use Ada.Text_IO;
procedure threadsumada is

   dim : constant integer := 100000;
   thread_num : constant integer := 2;

   arr : array(1..dim) of integer;

   procedure Init_Arr is
   begin
      for i in 1..dim loop
         arr(i) := i;
      end loop;
   end Init_Arr;

   function part_sum(start_index, finish_index : in integer) return long_long_integer is
      sum : long_long_integer := 0;
   begin
      for i in start_index..finish_index loop
         sum := sum + long_long_integer(arr(i));
      end loop;
      return sum;
   end part_sum;

   task type starter_thread is
      entry start(start_index, finish_index : in Integer);
   end starter_thread;

   protected part_manager is
      procedure set_part_sum(sum : in Long_Long_Integer);
      entry get_sum(sum : out Long_Long_Integer);
   private
      tasks_count : Integer := 0;
      sum1 : Long_Long_Integer := 0;
   end part_manager;

   protected body part_manager is
      procedure set_part_sum(sum : in Long_Long_Integer) is
      begin
         sum1 := sum1 + sum;
         tasks_count := tasks_count + 1;
      end set_part_sum;

      entry get_sum(sum : out Long_Long_Integer) when tasks_count = thread_num is
      begin
         sum := sum1;
      end get_sum;

   end part_manager;

   task body starter_thread is
      sum : Long_Long_Integer := 0;
      start_index, finish_index : Integer;
   begin
      accept start(start_index, finish_index : in Integer) do
         starter_thread.start_index := start_index;
         starter_thread.finish_index := finish_index;
      end start;
      sum := part_sum(start_index  => start_index,
                      finish_index => finish_index);
      part_manager.set_part_sum(sum);
   end starter_thread;

   function parallel_sum return Long_Long_Integer is
      sum : long_long_integer := 0;
      thread : array(1..thread_num) of starter_thread;
   begin
      thread(1).start(1, dim / 2);
      thread(2).start(dim / 2 + 1, dim);
      part_manager.get_sum(sum);
      return sum;
   end parallel_sum;

begin
   Init_Arr;
   Put_Line(part_sum(1, dim)'img);
   Put_Line(parallel_sum'img);
end threadsumada;
