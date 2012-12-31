# -*- coding: utf-8 -*-
#
# 木構造構造
#

require "kconv"

module Tree
  # 可視化
  #
  #   必要なメソッド
  #     tree_nodes (default: nodes)
  #     to_s_tree  (default: to_s)
  #
  module Visibler
    def tree(options = {}, &block)
      options = {
        # オプション相当
        :skip             => 0,     # 何レベルスキップするか？(1にするとrootを表示しない)
        :root_label       => nil,   # ルートを表示する場合に有効な代替ラベル
        :tab_space        => 4,     # 途中からのインデント幅
        :connect_char     => "├",
        :tab_visible_char => "│",
        :edge_char        => "└",
        :branch_char      => "─",
        :debug            => false, # わけがわからなくなったら true にしよう
        # テンポラリ
        :depth            => [],
      }.merge(options)

      if options[:depth].size > options[:skip]
        if self == parent.tree_nodes.last
          prefix_char = options[:edge_char]
        else
          prefix_char = options[:connect_char]
        end
      else
        prefix_char = ""
      end

      indents = options[:depth].each.with_index.collect{|flag, index|
        if index > options[:skip]
          tab = flag ? options[:tab_visible_char] : ""
          tab.toeuc.ljust(options[:tab_space]).toutf8
        end
      }.join

      if block_given?
        label = yield(self, options[:depth])
      else
        if options[:depth].empty? && options[:root_label] # ルートかつ代替ラベルがあれば変更
          label = options[:root_label]
        else
          label = to_s_tree
        end
      end

      branch_char = nil
      if options[:depth].size > options[:skip]
        branch_char = options[:branch_char]
      end

      if options[:depth].size >= options[:skip]
        buffer = "#{indents}#{prefix_char}#{branch_char}#{label}#{options[:debug] ? options[:depth].inspect : ""}\n"
      else
        buffer = ""
      end

      flag = false
      if parent
        flag = (self != parent.tree_nodes.last)
      end

      options[:depth].push(flag)
      buffer << tree_nodes.collect{|node|node.tree(options)}.join
      options[:depth].pop

      buffer
    end

    # 子供たち(オーバーライド推奨)
    def tree_nodes
      nodes
    end

    # 自分の名前(オーバーライド推奨)
    def to_s_tree
      to_s
    end
  end

  # サンプルなので別にこれを継承する必要はない
  class Node
    include Visibler

    attr_accessor :key, :parent, :nodes

    def initialize(key)
      @@auto_index ||= 0
      @@auto_index += 1
      @key = key || "#{@@auto_index}"
      @nodes = []
    end

    def to_s_tree
      @key
    end
  end
end
