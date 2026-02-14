NAME = x

# --- COMPILADOR E FLAGS ---
CC = cc
# Flags padrão exigidas pela 42 e boas práticas
CFLAGS = -Wall -Wextra -Werror
# -MMD -MP gera dependências automáticas de arquivos .h
CPPFLAGS = -MMD -MP -I ./includes

# --- DEBUG & SANITIZER FLAGS ---
# -g3: Informação máxima para debug (inclui macros)
# -O0: Sem otimizações para o código não "pular" linhas no GDB
DFLAGS = -g3 -O0
# AddressSanitizer (ASan): Detecta memory leaks e buffer overflows em runtime
AFLAGS = $(DFLAGS) -fsanitize=address

# --- CORES PARA OUTPUT ---
GREEN  = \033[0;32m
RED    = \033[0;31m
BLUE   = \033[0;34m
YELLOW = \033[0;33m
RESET  = \033[0m

# --- DIRETÓRIOS ---
SRCS_DIR  = src
OBJS_DIR  = objs
DEBUG_DIR = debug
ASAN_DIR  = asan
BIN_DIR   = bin

# --- ARQUIVOS (Busca recursiva) ---
# Encontra todos os arquivos .c dentro de src/ e subpastas
SRCS := $(shell find $(SRCS_DIR) -type f -name "*.c")

# Mapeia os objetos para suas respectivas pastas de build
OBJS       := $(patsubst $(SRCS_DIR)/%.c, $(OBJS_DIR)/%.o, $(SRCS))
OBJS_DEBUG := $(patsubst $(SRCS_DIR)/%.c, $(DEBUG_DIR)/%.o, $(SRCS))
OBJS_ASAN  := $(patsubst $(SRCS_DIR)/%.c, $(ASAN_DIR)/%.o, $(SRCS))

# Binários finais
TARGET       = $(BIN_DIR)/$(NAME)
DEBUG_TARGET = $(DEBUG_DIR)/$(NAME)
ASAN_TARGET  = $(ASAN_DIR)/$(NAME)

# Arquivos de dependência (.d)
DEPS := $(OBJS:.o=.d) $(OBJS_DEBUG:.o=.d) $(OBJS_ASAN:.o=.d)

# --- REGRAS PRINCIPAIS ---

# 1. Release (Uso padrão)
all: $(TARGET)

$(TARGET): $(OBJS)
	@mkdir -p $(BIN_DIR)
	@$(CC) $(CFLAGS) $(CPPFLAGS) $(OBJS) -o $@
	@printf "$(GREEN)🚀 Release binary created at $@$(RESET)\n"

$(OBJS_DIR)/%.o: $(SRCS_DIR)/%.c
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

# 2. Debug (Compila sem Sanitizers para GDB e Valgrind)
debug: $(DEBUG_TARGET)

$(DEBUG_TARGET): $(OBJS_DEBUG)
	@mkdir -p $(DEBUG_DIR)
	@$(CC) $(CFLAGS) $(DFLAGS) $(CPPFLAGS) $(OBJS_DEBUG) -o $@
	@printf "$(GREEN)🛠️  Debug binary created at $@$(RESET)\n"

$(DEBUG_DIR)/%.o: $(SRCS_DIR)/%.c
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) $(DFLAGS) $(CPPFLAGS) -c $< -o $@

# 3. ASan (Compila com AddressSanitizer)
asan: $(ASAN_TARGET)

$(ASAN_TARGET): $(OBJS_ASAN)
	@mkdir -p $(ASAN_DIR)
	@$(CC) $(CFLAGS) $(AFLAGS) $(CPPFLAGS) $(OBJS_ASAN) -o $@
	@printf "$(YELLOW)⚠️  ASan binary created at $@$(RESET)\n"

$(ASAN_DIR)/%.o: $(SRCS_DIR)/%.c
	@mkdir -p $(@D)
	@$(CC) $(CFLAGS) $(AFLAGS) $(CPPFLAGS) -c $< -o $@

# --- ATALHOS DE FERRAMENTAS ---

# Inicia o GDB com interface visual (TUI)
gdb: debug
	@printf "$(BLUE)🐛 Starting GDB...$(RESET)\n"
	gdb $(DEBUG_TARGET) -tui

# Roda o Valgrind com flags completas de detecção
valgrind: debug
	@printf "$(BLUE)🔍 Starting Valgrind...$(RESET)\n"
	valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./$(DEBUG_TARGET)

# Roda o binário compilado com ASan (que reporta erros no terminal)
run_asan: asan
	@printf "$(YELLOW)🧪 Running with ASan...$(RESET)\n"
	./$(ASAN_TARGET)

run: $(TARGET)
	@printf "$(GREEN)🎲Running $(NAME)...$(RESET)\n"
	@./$(TARGET)

# --- LIMPEZA ---

clean:
	@rm -rf $(OBJS_DIR) $(DEBUG_DIR) $(ASAN_DIR)
	@printf "$(RED)🧹 Object folders removed.$(RESET)\n"

fclean: clean
	@rm -rf $(BIN_DIR)
	@printf "$(RED)💥 Binaries removed.$(RESET)\n"

re: fclean all

# Inclui dependências de headers para forçar recompilação se um .h mudar
-include $(DEPS)

.PHONY: all clean fclean re debug asan gdb valgrind run_asan
