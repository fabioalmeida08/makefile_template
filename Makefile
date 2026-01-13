NAME = x

# FLAGS
CC = cc
CFLAGS = -Wall -Wextra -Werror
CPPFLAGS = -MMD -MP -I ./includes
MAKEFLAGS += --no-print-directory

# CMDS
DIR_DUP = mkdir -p $(@D)

# COLORS
GREEN = \033[0;32m
RED = \033[0;31m
BLUE = \033[0;34m
RESET = \033[0m

# DIRS
SRCS_DIR = src
OBJS_DIR = objs
BIN_DIR = bin
TARGET = $(BIN_DIR)/$(NAME)

# FILES
SRCS := x.c
SRCS := $(addprefix $(SRCS_DIR)/, $(SRCS))
OBJS := $(patsubst $(SRCS_DIR)/%.c, $(OBJS_DIR)/%.o, $(SRCS))
DEPS := $(OBJS:.o=.d)

# RULES
all: $(TARGET)

$(TARGET): $(OBJS)
	@(DIR_DUP)
	@$(CC) $(CFLAGS) $(CPPFLAGS) $(OBJS) -o $@
	@echo "$(GREEN)🛠️ Finished compiling $(NAME) objects$(RESET)"
	@echo "$(GREEN)🚀 $@ was created$(RESET)"

$(OBJS_DIR)/%.o: $(SRCS_DIR)/%.c
	@$(DIR_DUP)
	@$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

-include $(DEPS)

clean:
	@rm -rf $(OBJS_DIR)
	@echo "$(RED)🧹 $(NAME) objects removed$(RESET)"

fclean: clean
	@rm -rf $(TARGET)
	@echo "$(RED)💥 $(NAME) deleted$(RESET)"

re: fclean all
	@echo "$(BLUE)🔄 $(NAME) rebuild$(RESET)"

.PHONY: all clean fclean re
